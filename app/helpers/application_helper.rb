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
  # param [String] country_code  as specified in locale file
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
  # @param [#state] r  the request, reimbursement or any other object with state
  # @return [String] HTML output
  def timestamped_state(r)
    date = r.send("#{r.state}_since")
    msg = content_tag(:span, r.human_state_name, :class => r.state)
    msg += " " +  t(:since, :date => l(date, :format => :short)) unless date.blank?
    raw(msg)
  end 

  # Outputs a link with an icon inside (and visible no text)
  #
  # @param [String] name   a icon name from http://twitter.github.com/bootstrap/base-css.html#icons
  # @param [String] path   url for the link
  # @param [Hash] options  options for #url_for. A :title option is highly recommended
  # @return [String] HTML output
  def icon_to(name, path, options = {})
    link_to(content_tag(:i, "", :class => "icon-#{name}"), path, options)
  end

  # Outputs a trigger for (un)collapsing a target element
  #
  # @param [String] target  id of the HTML element to (un)collapse
  # @return [String] HTML output
  def collapse_link(target)
    icon_to "resize-vertical", "\##{target}", :title => t(:collapse), :data => {:toggle => :collapse}
  end
end
