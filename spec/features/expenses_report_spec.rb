# frozen_string_literal: true

require 'spec_helper'
# require 'ruby-debug'

feature 'ExpenseRequest', '' do
  fixtures :all

  scenario 'Approved report' do
    sign_in_as_user(users(:tspmember))
    visit travel_expenses_report_path
    page.should have_content 'expenses report'
    select 'approved', from: 'by_type'
    select 'user', from: 'by_group'
    click_button 'html'
    # Within the first row (skipping the header) of the results table
    within(:xpath, "(//table[contains(@class, 'expense-reports')]//tr)[2]") do
      page.should have_content 'tatooine69' # Luke
      page.should have_content '110.00'
      page.should_not have_content 'red_two' # Wedge
    end
    # Within the second row
    within(:xpath, "(//table[contains(@class, 'expense-reports')]//tr)[3]") do
      page.should have_content 'red_two'
      page.should have_content '70.00'
    end
  end

  scenario 'Restricted estimated report' do
    sign_in_as_user(users(:luke))
    visit travel_expenses_report_path
    select 'estimated', from: 'by_type'
    select 'event', from: 'by_group'
    click_button 'html'
    # Only two lines, with luke's amounts
    within(:xpath, "(//table[contains(@class, 'expense-reports')]//tr)[2]") do
      page.should have_content '260.00'
    end
    within(:xpath, "(//table[contains(@class, 'expense-reports')]//tr)[3]") do
      page.should have_content '100.00'
    end
    page.should_not have_xpath("(//table[contains(@class, 'expense-reports')]//tr)[4]")
  end
end
