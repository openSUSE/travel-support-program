# frozen_string_literal: true

require 'spec_helper'
# require 'ruby-debug'

feature 'Reimbursement authorized amount', '' do
  fixtures :all

  scenario 'Mixing currencies', js: true do
    # Tweak the request a little bit so currencies are combined
    request = requests(:luke_for_yavin)
    request.expenses.where(subject: 'Lodging').first.update_column(:estimated_currency, 'USD')

    # Let's create the reimbursement...
    sign_in_as_user(users(:luke))
    visit travel_sponsorship_path(requests(:luke_for_yavin))
    click_link 'Ask for reimbursement'

    # ...and take a look to the form
    page.should have_content 'reimbursement was successfully created'
    page.should have_content 'the authorized amount must be explicitly set'
    page.should have_xpath("//thead[@id='expenses_head']//tr//th[contains(.,'authorized')]")
    # The 'Gas' expense have a field for total...
    within(:xpath, "//tbody[@id='expenses']//tr[td[contains(.,'Gas')]]//td[@class='total']") do
      page.should have_selector 'input'
      find('input').set '500'
    end
    # ...but not for authorized
    within(:xpath, "//tbody[@id='expenses']//tr[td[contains(.,'Gas')]]//td[@class='authorized']") do
      page.should have_content 'EURXX'
      page.should_not have_selector 'input'
    end
    # The 'Lodgin' expense should have both inputs
    within(:xpath, "//tbody[@id='expenses']//tr[td[contains(.,'Lodging')]]//td[@class='total']") do
      page.should have_selector 'input'
      find('input').set '400'
    end
    within(:xpath, "//tbody[@id='expenses']//tr[td[contains(.,'Lodging')]]//td[@class='authorized']") do
      page.should have_selector 'input'
      find('input').set '321'
      page.should_not have_content 'EURXX'
    end

    # Ensure that the authorized value is there after saving
    click_button 'Update reimbursement'
    page.should have_content 'reimbursement was successfully updated'
    within(:xpath, "//tbody[@id='expenses']//tr[td[contains(.,'Lodging')]]//td[@class='authorized']") do
      page.should have_content 'EUR321'
    end
  end
end
