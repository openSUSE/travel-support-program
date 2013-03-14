class Request < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_many :expenses, :class_name => "RequestExpense", :inverse_of => :request

  accepts_nested_attributes_for :expenses, :reject_if => :all_blank, :allow_destroy => true

  attr_accessible :event_id, :requester_notes, :tsp_notes, :expenses_attributes

  validates :event, :presence => true

  state_machine :state, :initial => :incomplete do
    before_transition do |request, transition|
      request.set_transition_datetime(transition)
    end

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

  scope :editable_by_requester, :state => "incomplete"
  scope :editable_by_tsp, :state => "submitted"

  def editable_by_requester?
    state == 'incomplete'
  end

  def editable_by_tsp?
    state == 'submitted'
  end

  def can_be_destroyed?
    submitted_since.nil?
  end

  def set_transition_datetime(transition)
    write_attribute("#{transition.to}_since".to_sym, DateTime.now)
  end
end
