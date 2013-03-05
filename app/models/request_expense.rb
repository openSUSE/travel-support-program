class RequestExpense < ActiveRecord::Base
  belongs_to :request

  attr_accessible :request_id, :subject, :description, :total_amount, :total_currency, :approved_amount, :approved_currency

  validates :request, :presence => true
end
