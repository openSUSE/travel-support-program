module RequestsHelper
  def timestamped_state(request)
    date = request.send("#{request.state}_since")
    msg = content_tag(:span, request.human_state_name, :class => request.state)
    msg += " " +  t(:since, :date => l(date, :format => :short)) unless date.blank?
    raw(msg)
  end
end

