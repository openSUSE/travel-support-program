require 'spec_helper'
#require 'ruby-debug'

feature "Shipment", "" do
  fixtures :all

  scenario "Full shipment process", :js => true do
    sign_in_as_user(users(:luke))
    visit event_path(events(:hoth_hackaton))
    click_link "Merchandising"

    # Shipment creation
    page.should have_content "New shipment"
    fill_in "shipment_description", :with => "I need it to explain how to use it to other pilots."
    fill_in "shipment_delivery_address", :with => "Send it to the base."
    click_button "Create shipment"
    page.should have_content "shipment was successfully created"
    page.should have_content "shipment must be explicitly requested."
    @shipment = Shipment.order(:created_at, :id).last

    # Testing audits, just in case
    @shipment.audits.order("created_at, id").last.user.should == users(:luke)

    # Initial request
    click_link "Action"
    click_link "Request"
    click_button "request"
    page.should have_content "Successfully requested."
    page.should have_content "from incomplete to requested"
    page.should have_content "waiting for approval"

    # Try to update
    page.should_not have_content "Edit"
    visit edit_shipment_path(@shipment)
    page.status_code.should == 403

    # Log in as material manager
    click_link "Log out"
    find_shipment_as(users(:material), @shipment)

    # Roll back
    click_link "Action"
    click_link "Roll Back"
    fill_in "notes", :with => "We need a valid postal delivery address."
    click_button "roll back"
    page.should have_content "Successfully rolled back"
    page.should have_content "from requested to incomplete"
    page.should have_content "requester must update all the relevant information"

    # Log in as requester
    click_link "Log out"
    find_shipment_as(users(:luke), @shipment)

    # Update the shipment
    visit shipment_path(@shipment)
    click_link "Edit"
    page.should have_content "Edit shipment"
    fill_in "shipment_delivery_address", :with => "Luke Skywalker\nSecret Rebel base at Hoth"
    click_button "Update shipment"
    page.should have_content "shipment was successfully updated"

    # And request it again
    click_link "Action"
    click_link "Request"
    fill_in "notes", :with => "Added postal address"
    click_button "request"
    page.should have_content "Successfully requested."
    page.should have_content "from incomplete to requested"

    # Log in as material manager
    click_link "Log out"
    find_shipment_as(users(:material), @shipment)

    # Approval
    click_link "Action"
    click_link "Approve"
    fill_in "notes", :with => "Use with care."
    click_button "approve"
    page.should have_content "Successfully approved"
    page.should have_content "from requested to approved"
    page.should have_content "will be now sent"

    # Log in as shipper
    click_link "Log out"
    find_shipment_as(users(:shipper), @shipment)

    # And send the material
    click_link "Action"
    click_link "Dispatch"
    fill_in "notes", :with => "Interstelar track code: IAWY332"
    click_button "dispatch"
    page.should have_content "Succesfully dispatched."
    page.should have_content "from approved to sent"
    page.should have_content "traveling"
    page.should have_content "the requester must confirm the shipment in the application"

    # Log in as requester
    click_link "Log out"
    find_shipment_as(users(:luke), @shipment)

    # And confirm the reception
    click_link "Action"
    click_link "Confirm"
    fill_in "notes", :with => "Half of the imperial fleet is here to deliver the package. We should have been more discreet."
    click_button "confirm"
    page.should have_content "Confirmation processed"
    page.should have_content "from sent to received"
    page.should have_content "Final state"
  end
end
