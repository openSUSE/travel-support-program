#
# Request that needs a reimbursement after reaching the final state
#
# Subclasses must implement the can_have_reimbursement method.
#
class ReimbursableRequest < Request
  # Estimated expenses, including (for every expense) the estimated amount,
  # the amount of the help that the corresponding committee aproves, the
  # amount finally expended and the amount that is going to be reimbursed
  has_many :expenses, class_name: 'RequestExpense',
                      foreign_key: 'request_id',
                      inverse_of: :request,
                      dependent: :destroy

  # Every accepted request is followed by a reimbursement process
  has_one :reimbursement, inverse_of: :request,
                          foreign_key: 'request_id',
                          dependent: :restrict_with_exception

  accepts_nested_attributes_for :expenses, reject_if: :all_blank, allow_destroy: true

  validates_associated :expenses

  # Checks is expenses.empty?
  #
  # This one line method is required in order to the Graphviz automatic
  # documentation to work, because it doesn't work if a string is used in the
  # :unless parameter of a event definition
  def has_no_expenses?
    expenses.empty?
  end

  # Checks whether can have a transition to 'canceled' state
  #
  # Overrides the HasState.can_cancel?, preventing cancelation of requests that
  # already have an active reimbursement
  # @see HasState.can_cancel?
  #
  # return [Boolean] true if #cancel can be called
  def can_cancel?
    !canceled? && (reimbursement.nil? || !reimbursement.active?)
  end

  # Checks whether a request is ready for reimbursement but the process have not
  # yet started
  #
  # @return [Boolean] if there is no associated reimbursement
  def lacks_reimbursement?
    can_have_reimbursement? && (reimbursement.nil? || reimbursement.new_record?)
  end

  # Summarizes one of the xxx_amount attributes from the request's expenses grouping
  # it by currency.
  #
  # A value of nil for the amount is ignored (the currency will not be present
  # in the result if all related amounts are nil), but zeros are counted (so the
  # currency will be present even if all the corresponding amounts are 0.0).
  #
  # All the calculations are done in pure ruby (no SQL involved), so be sure to
  # use includes(:expenses) when using it through an ActiveRecord::Relation
  #
  # @param [Symbol] attr Attribute to summarize, can be :estimated, :approved,
  #   :total or :authorized
  # @return [ActiveSupport::OrderedHash] with currencies as keys and sums as value,
  #     ordered by currencies' alphabetic order
  def expenses_sum(attr = :total)
    grouped = expenses.group_by(&:"#{attr}_currency")
    nonils = grouped.each { |_k, v| v.delete_if { |i| i.send(:"#{attr}_amount").nil? } }.delete_if { |_k, v| v.empty? }
    unordered = nonils.map { |k, v| [k, v.sum(&:"#{attr}_amount")] }
    ActiveSupport::OrderedHash[unordered.sort_by(&:first)]
  end

  def self.expenses_sum(attr = :total, requests)
    amount_field = :"#{attr}_amount"
    r_ids = if requests.is_a?(ActiveRecord::Relation)
              requests.reorder('').pluck('requests.id')
            else
              requests.map { |i| i.is_a?(Integer) ? i : i.id }
            end
    RequestExpense.by_attr_for_requests(attr, r_ids).sum(amount_field)
  end
end
