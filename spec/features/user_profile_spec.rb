# encoding: utf-8
require 'spec_helper'

feature "Edit my account", "" do
  fixtures :all

  background do
    I18n.locale = :en
    sign_in_as_user(users(:anakin))
    click_link "imbetterthanyou"
  end

  scenario "Edit profile data" do
    click_link "Profile"
    fill_in "user[phone_number]", :with => "+99 555 343 3433"
    fill_in "second phone number", :with => "+99 555 343 3433"
    fill_in "description", :with => "I was an interesting character in the REAL trilogy. Now I'm CR7."
    fill_in "website", :with => "http://www.starwars.com/anakin/"
    click_button "Update profile"
    page.should have_content "Profile information updated"
  end

  scenario "Change password" do
    click_link "Password"
    fill_in "user[password]", :with => "new_password"
    fill_in "user[password_confirmation]", :with => "new_password"
    click_button "Change password"
    page.should have_content "Password updated"
  end

  scenario "Change account" do
    click_link "Account"
    fill_in "Nickname", :with => "Darth Vader"
    fill_in "Email", :with => "vader@empire.gob"
    click_button "Update user"
    page.should have_content "Your account was updated"
  end

  scenario "Change account without name" do
    click_link "Account"
    fill_in "Nickname", :with => ""
    fill_in "Email", :with => "vader@empire.gob"
    click_button "Update user"
    page.should have_content "Your account wasn't updated"
  end
end


