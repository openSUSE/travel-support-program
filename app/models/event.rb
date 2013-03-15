class Event < ActiveRecord::Base
  attr_accessible :name, :description, :start_date, :end_date, :url, :country_code, :validated
  has_many :requests, :inverse_of => :event

  def editable_by_requesters?
    not validated
  end

  def can_be_destroyed?
    requests.empty?
  end

  def self.validation_attributes
    [:validated]
  end
end
