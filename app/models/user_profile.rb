class UserProfile < ActiveRecord::Base
  belongs_to :user

  attr_accessible :country_code, :full_name, :phone_number
end
