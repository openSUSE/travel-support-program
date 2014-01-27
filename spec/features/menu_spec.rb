# encoding: utf-8
require 'spec_helper'

feature "Menu", "" do
  fixtures :all

  scenario "as requester" do
    sign_in_as_user(users(:anakin))
    find("#options").should have_link "Requests", :href => requests_path
    find("#options").should have_link "Reimbursements", :href => reimbursements_path
  end

  scenario "as tsp member" do
    sign_in_as_user(users(:tspmember))
    find("#options").should have_link "Requests", :href => requests_path(:q => {:state_eq => "submitted"})
    find("#options").should have_link "Reimbursements", :href => reimbursements_path(:q => {:state_eq => "submitted"})
  end

  scenario "as assistant" do
    sign_in_as_user(users(:assistant))
    find("#options").should have_link "Requests", :href => requests_path(:q => {:state_eq => "submitted"})
    find("#options").should have_link "Reimbursements", :href => reimbursements_path(:q => {:state_eq => "submitted"})
  end

  scenario "as administrative" do
    sign_in_as_user(users(:administrative))
    find("#options").should have_link "Requests", :href => requests_path
    find("#options").should have_link "Reimbursements", :href => reimbursements_path(:q => {:state_eq => "accepted"})
  end
end
