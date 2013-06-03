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
    fill_in "reimbursement_request_attributes_expenses_attributes_0_total_amount", :with => "120"
    fill_in "reimbursement_request_attributes_expenses_attributes_1_total_amount", :with => "50"
    fill_in "reimbursement_request_attributes_expenses_attributes_2_total_amount", :with => "100"
    click_button "Update reimbursement"
    page.should have_content "reimbursement was successfully updated"
    @reimbursement = Reimbursement.order(:created_at).last

    # Testing audits, just in case
    @reimbursement.audits.last.user.should == users(:luke)
    @reimbursement.expenses.first.audits.last.user.should == users(:luke)
  end
end
