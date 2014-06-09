#
# ActiveHash containing the application user's roles
#
class UserRole < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { :id => 1, :name => 'requester' },
    { :id => 2, :name => 'tsp' },
    { :id => 3, :name => 'supervisor' },
    { :id => 4, :name => 'administrative'},
    { :id => 5, :name => 'assistant' },
    { :id => 6, :name => 'admin' }            # new user role to monitor the customisation of state machines
  ]

  enum_accessor :name

  def title
    I18n.t(name, :scope => "activehash.user_role")
  end
end
