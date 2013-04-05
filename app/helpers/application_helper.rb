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
    msg = content_tag(:span, r.human_state_name, :class => r.state)
    msg += " " +  t(:since, :date => l(r.state_updated_at, :format => :short)) unless r.state_updated_at.blank?
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

  # Outputs the role of the current user. Useful, for example, for deciding which partial
  # view should be used.
  def current_role
    current_user.find_profile.role_name
  end

  # Checks if the current user belongs to a given role
  #
  # @param [#to_s] role
  # @return [Boolean] true if the current users has the given role
  def current_role?(role)
    current_role == role.to_s
  end

  # Outputs a list of links to create every possible and
  # authorized state transition for a given state machine
  #
  # @param [#state_events]  machine  a request or a reimbursement (or any other
  #                                  object including the HasState mixin)
  # @return [String] a list of space separated links
  def transition_links(machine)
    trans_path = resource_path + "/state_transitions/new.js?state_transition[state_event]="
    machine.state_events.map do |event|
      next unless can? event, machine
      link_to t("activerecord.state_machines.events.#{event}"), trans_path + event.to_s, :remote => true, :class => 'btn'
    end.join(" ").html_safe
  end

  # URL for accesing to a given request or reimbursement
  #
  # This helper deals with the singleton issues in the reimbursement routes
  # definition.
  def machine_url(machine)
    if machine.kind_of?(Request)
      request_url(machine)
    else
      request_reimbursement_url(machine.request)
    end
  end

  # Path to the list of requests or reimbursements with the ransack filters
  # already configured based on the assign_state definitions of the
  # corresponding class.
  #
  # @see HasState.assign_state
  def menu_path_to(machine_class)
    helper = machine_class.model_name.tableize + "_path"
    states = machine_class.states_assigned_to(current_role)
    if states.size == 1
      send(helper, :q => {:state_eq => states.first})
    else
      send helper
    end
  end

  # Outputs the flash messages in a bootstrap optimized way
  #
  # Stolen from https://github.com/seyhunak/twitter-bootstrap-rails
  def bootstrap_flash_messages
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = :success if type == :notice
      type = :error if type == :alert
      next unless [:error, :info, :success, :warning].include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                           msg.html_safe, :class => "alert fade in alert-#{type}")
        flash_messages << text if message
      end
    end
    flash_messages.join("\n").html_safe
  end

  # Currency codes that can be selected for a given field
  #
  # @param [#to_s]  field  Name of the field as specified in the site.yml file,
  #            like 'estimated' or 'approved'
  # @return [Array]  Array with the currency codes
  def currencies_for_select(field)
    currencies = TravelSupportProgram::Config.setting("currencies_for_#{field}")
    currencies ||= I18n.translate(:currencies).keys.sort
  end

end
