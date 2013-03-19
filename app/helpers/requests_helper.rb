module RequestsHelper
  # Outputs the sum of the expenses of a request, as a list of comma
  # separated number_to_currency (one for every used currency)
  #
  # @param [Symbol] attr can be :total or :approved
  # @return [String] HTML output
  def request_sum(request, attr)
    request.expenses_sum(attr).map {|k,v| number_to_currency(v, :unit => (k || "?"))}.join(", ")
  end
end

