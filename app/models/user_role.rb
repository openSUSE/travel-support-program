class UserRole < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { :name => 'requester' },
    { :name => 'tsp' },
    { :name => 'supervisor' },
    { :name => 'administrative'} 
  ]

  enum_accessor :name

  def title
    I18n.t(name, :scope => "activehash.user_role")
  end
end
