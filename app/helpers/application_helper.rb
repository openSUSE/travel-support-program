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

  def transition_links_for_reimbursement(reimbursement)
    reimbursement.state_events.map do |event|
      next unless can? event, reimbursement
      # FIXME
      # If the object can be manipulated, we need a form. This check is
      # TEMPORARY and it needs to be rewritten as part of the state machines
      # refactorization
      if Reimbursement.editable_in?(event)
        link_to t("activerecord.state_machines.events.#{event}"), new_request_reimbursement_transition_path(reimbursement.request, :transition => {:action => event.to_s}), :class => 'btn'
      else
        link_to t("activerecord.state_machines.events.#{event}"), request_reimbursement_transitions_path(reimbursement.request, :transition => {:action => event.to_s}), :method => :post, :data => { :confirm => t("helpers.links.confirm") }, :class => 'btn'
      end
    end.join(" ").html_safe
  end

  # Outputs the sum of the expenses of a request or a reimbursement,
  # as a list of comma separated number_to_currency (one for
  # every used currency)
  #
  # @param [#expenses_sum] r a request or a reimbursement
  # @param [Symbol] attr can be :estimated, :approved, :total or :authorized
  # @return [String] HTML output
  def expenses_sum(r, attr)
    r.expenses_sum(attr).map {|k,v| number_to_currency(v, :unit => (k || "?"))}.join(", ")
  end

  def current_role
    current_user.find_profile.role_name
  end

  def current_role?(role)
    current_role == role.to_s
  end
end
