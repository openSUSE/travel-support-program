require 'spec_helper'
#require 'ruby-debug'

feature "Reimbursements", "" do
  fixtures :all

  scenario "Full reimbursement process" do
    sign_in_as_user(users(:luke))
    visit request_path(requests(:luke_for_yavin))
    # To avoid ambiguity
    within(:xpath, "//div[@class='form-actions']") do
      click_link "Ask for reimbursement"
    end

    # Request creation
    page.should have_content "reimbursement was successfully created"
    fill_in "reimbursement_description", :with => "Hey, I destroyed the Death Star so I deserve the reimbursement."
    fill_in "holder", :with => "Owen Lars"
    fill_in "financial institution", :with => "Tatooine Saving Bank"
    fill_in "account IBAN", :with => "TT123456789012"
    fill_in "account BIC/SWIFT code", :with => "0987654"
    within(:xpath, "//tbody[@id='expenses']//tr[td[contains(.,'Gas')]]") do
      find('input').set "120"
    end
    within(:xpath, "//tbody[@id='expenses']//tr[td[contains(.,'Droid rental')]]") do
      find('input').set "50"
    end
    click_button "Update reimbursement"
    page.should have_content "reimbursement was successfully updated"
    @reimbursement = Reimbursement.order(:created_at).last

    # Failed submission
    click_link "Action"
    click_link "submit"
    fill_in "notes", :with => "I've not fulfilled one of the amounts"
    click_button "submit"
    page.should have_content "Something went wrong. Unable to submit."

    # Correct the request
    click_link "Edit"
    page.should have_content "Edit reimbursement"
    within(:xpath, "//tbody[@id='expenses']//tr[td[contains(.,'Lodging')]]") do
      find('input').set "100"
    end
    click_button "Update reimbursement"
    page.should have_content "reimbursement was successfully updated"

    # Testing audits, just in case
    @reimbursement.audits.last.user.should == users(:luke)
    @reimbursement.expenses.first.audits.last.user.should == users(:luke)

    # Submit again
    click_link "Action"
    click_link "submit"
    fill_in "notes", :with => "Ok, now all the information is there."
    click_button "submit"
    page.should have_content "Successfully submitted."
    page.should have_content "From incomplete to submitted"

    # Log in as tspmember
    click_link "Log out"
    find_reimbursement_as(users(:tspmember), @reimbursement)

    # Rolling back
    click_link "Action"
    click_link "roll back"
    fill_in "notes", :with => "Sorry Mr. Idestroyedthedeathstar: no invoices, no money"
    click_button "roll back"
    page.should have_content "Successfully rolled back."

    # Log in as requester
    click_link "Log out"
    find_reimbursement_as(users(:luke), @reimbursement)

    # Add links and attachments
    click_link "Edit"
    page.should have_content "Edit reimbursement"
    click_link "add link"
    within(:xpath, "//tbody[@id='links']//tr[@class='nested-fields'][last()]") do
      find('input[name$="[title]"]').set "Video recording of my intervention"
      find('input[name$="[url]"]').set "http://www.youtube.com/watch?v=DOFgFAcGHQc"
    end
    click_link "add attachment"
    show_jasny_file_inputs "#attachments input[name$='[file]']"
    within(:xpath, "//tbody[@id='attachments']//tr[@class='nested-fields'][last()]") do
      find('input[name$="[title]"]').set "Lodging receipt"
      find('input[name$="[file]"]').set Rails.root.join("spec", "support", "files", "scan001.pdf")
    end
    click_link "add attachment"
    show_jasny_file_inputs "#attachments input[name$='[file]']"
    within(:xpath, "//tbody[@id='attachments']//tr[@class='nested-fields'][last()]") do
      find('input[name$="[title]"]').set "Gas receipt"
      find('input[name$="[file]"]').set Rails.root.join("spec", "support", "files", "scan001.pdf")
    end
    click_button "Update reimbursement"
    page.should have_content "reimbursement was successfully updated"

    # And submit again
    click_link "Action"
    click_link "submit"
    fill_in "notes", :with => "Here you are the invoices. Make sure you also watch the video."
    click_button "submit"
    page.should have_content "Successfully submitted."

    # Log in as tspmember
    click_link "Log out"
    find_reimbursement_as(users(:tspmember), @reimbursement)

    # Approving if all invoices are there
    page.should have_content "Video recording"
    page.should have_content "Lodging receipt"
    page.should have_content "Gas receipt"
    click_link "Action"
    click_link "approve"
    fill_in "notes", :with => "Everything ok know."
    click_button "approve"
    page.should have_content "Successfully approved."

    # Log in as requester
    click_link "Log out"
    find_reimbursement_as(users(:luke), @reimbursement)

    # The signature notification (and the button) should be there...
    page.should have_content "An updated signed version of the reimbursement request is required"
    page.should have_link "Attach signature"
    page.should have_link "Printable version"
    # ..but our hero decides to ignore it
    click_link "Action"
    click_link "accept"
    fill_in "notes", :with => "I don't sign autograph for free."
    click_button "accept"
    page.should have_content "Not accepted"
    # No way. Time to attach
    click_link "Attach signature"
    page.should have_content "Print it, sign it, scan the signed version and upload it using the form below"
    attach_file "acceptance_file", Rails.root.join("spec", "support", "files", "scan001.pdf")
    click_button "Attach signature"
    page.should have_content "scan001.pdf"
    # Accept again
    click_link "Action"
    click_link "accept"
    fill_in "notes", :with => "Acceptance included."
    click_button "accept"
    page.should have_content "Acceptance processed"
    page.should_not have_link "Action"

    # Log in as tsp member
    click_link "Log out"
    find_reimbursement_as(users(:tspmember), @reimbursement)

    # Nothing to do, time for the administrative
    page.should_not have_link "Action"

    # Log in as administrative
    click_link "Log out"
    find_reimbursement_as(users(:administrative), @reimbursement)
    # Process the reimbursement
    click_link "Action"
    click_link "process"
    fill_in "notes", :with => "Every ok. Sending to accounting dept."
    click_button "process"
    page.should have_content "Payment processed"
    # And mark it as payed
    click_link "Action"
    click_link "confirm"
    click_button "confirm"
    page.should have_content "Confirmation processed"
  end
end
