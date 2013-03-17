module RequestsHelper
  # Outputs the state of the request with the appropiate css class
  # and the associated date
  #
  # @return [String] HTML output
  def timestamped_state(request)
    date = request.send("#{request.state}_since")
    msg = content_tag(:span, request.human_state_name, :class => request.state)
    msg += " " +  t(:since, :date => l(date, :format => :short)) unless date.blank?
    raw(msg)
  end 

  # Outputs the sum of the expenses of a request, as a list of comma
  # separated number_to_currency (one for every used currency)
  #
  # @param [Symbol] attr can be :total or :approved
  # @return [String] HTML output
  def request_sum(request, attr)
    request.expenses_sum(attr).map {|k,v| number_to_currency(v, :unit => (k || "?"))}.join(", ")
  end
end

