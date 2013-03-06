# encoding: utf-8
require 'spec_helper'

feature "User registration and password recovery", "" do
  fixtures :users, :user_profiles

  scenario "Register as user" do
    visit root_path
    click_link "Sign up"
    fill_in "Nickname", :with => "Han"
    fill_in "Email", :with => "hansolo@contrabandists.com"
    fill_in "user[password]", :with => "HanShotFirst"
    fill_in "user[password_confirmation]", :with => "HanShotFirst"
    click_button "Sign up"
    page.should have_content "Welcome! You have signed up successfully"
    page.should have_content "Log out"
  end

  scenario "Recover password" do
    visit root_path
    click_link "Log in"
    click_link "Forgot password?"
    fill_in "Email", :with => users(:luke).email
    click_button "Send"
    page.should have_content "You will receive an email with instructions about how to reset your password in a few minutes."
    current_path.should == new_user_session_path

    # Follow link in instructions e-mail.
    open_email(users(:luke).email)
    current_email.click_link "Change my password"
    fill_in "user[password]", :with => "12345678"
    fill_in "user[password_confirmation]", :with => "12345678"
    click_button "Change"
    page.should have_content "Your password was changed successfully. You are now signed in."
    current_path.should == root_path
  end

end
