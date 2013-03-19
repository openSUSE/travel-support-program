module ApplicationHelper
  # Outputs a <li> element suitable for use in Bootstrap nav menus, that is,
  # with the 'active' css class when needed
  #
  # param [String] label Text to display
  # param [String] path  Target URL
  # return [String] HTML output
  def nav_tab(label, path)
    css = current_page?(path) ? "active" : nil
    content_tag(:li, link_to(t(label), path), :class => css)
  end

  # Outputs country code in a human readable and localized way, using the locale
  # file for localized_country_select
  #
  # param [String] country_code The ISO
  # return [String] HTML output
  def country_label(country_code)
    if country_code.nil?
      t("show_for.blank")
    else
      country_code + " - " + t("countries.#{country_code}")
    end
  end

  # Outputs the state of a model instance with the appropiate
  # css class and the associated date
  #
  # @params [#state] the request, reimbursement or any other object with state
  # @return [String] HTML output
  def timestamped_state(r)
    date = r.send("#{r.state}_since")
    msg = content_tag(:span, r.human_state_name, :class => r.state)
    msg += " " +  t(:since, :date => l(date, :format => :short)) unless date.blank?
    raw(msg)
  end 
end
