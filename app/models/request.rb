class Request < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  attr_accessible :event_id

  validates :event, :presence => true

end
