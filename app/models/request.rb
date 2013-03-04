class Request < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  attr_accessible :event_id

  validates :event, :presence => true

  state_machine :state, :initial => :incomplete do

    event :submit do
      transition :incomplete => :submitted
    end

    event :approve do
      transition :submitted => :approved
    end

    event :accept do
      transition :approved => :accepted
    end

    event :reject do
      transition  [:submitted, :approved] => :incomplete
    end

    event :cancel do
      transition [:incomplete, :submitted, :approved] => :canceled
    end
  end
end
