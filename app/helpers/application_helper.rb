#
# Application-wide helpers
#
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
    if country_code.blank?
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
    msg += " " +  t(:since, :date => l(r.state_updated_at, :format => :long)) unless r.state_updated_at.blank?
    raw(msg)
  end 

  # Outputs the state of a model instance with a help tooltip if needed
  #
  # @param [#state] r  the request, reimbursement or any other object with state
  # @return [String] HTML output
  def state_info(r)
    msg = content_tag(:span, r.human_state_name, :class => r.state)
    msg += " (#{r.human_state_description})"
    if r.state_updated_at.blank?
      msg += " "
      msg += content_tag(:span, "!", :title => t(:state_help), :class => "badge badge-warning with-tooltip")
    end
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
  # @param [String] label  additional text to prepend to the icon
  # @return [String] HTML output
  def collapse_link(target, label='')
    label << " " unless label.empty?
    link_to(label.html_safe + content_tag(:i, "", :class => "icon-resize-vertical"),
            "\##{target}", :title => t(:collapse), :data => {:toggle => :collapse})
  end

  # Outputs a link with the "go to" label and an icon
  #
  # @param [String] path  url for the link
  # @return [String] HTML output
  def goto_link(path)
    link_to("#{t(:goto)} ".html_safe + content_tag(:i, "", :class => "icon-share-alt"),
            path, :title => t(:goto))
  end

  # Outputs the sum of the expenses of a request or a reimbursement
  # (or for a collection of requests/reimbursents),
  # as a list of comma separated number_to_currency (one for
  # every used currency)
  #
  # @param [Object] r a request, a reimbursement or a collection (reimbursements
  #                   or request, not mixed)
  # @param [Symbol] attr can be :estimated, :approved, :total or :authorized
  # @return [String] HTML output
  def expenses_sum(r, attr)
    if r.respond_to?(:size)
      if first = r.first
        sum = first.class.expenses_sum(attr, r)
      else
        sum = []
      end
    else
      sum = r.expenses_sum(attr)
    end
    sum.map {|k,v| number_to_currency(v, :unit => (k || "?"))}.join(", ")
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
  # authorized state transition for a given state machine.
  # If the user is authorized, it also adds the 'cancel' and 'adjust state'
  # options.
  #
  # @param [#state_events]  machine  a request or a reimbursement (or any other
  #                                  object including the HasState mixin)
  # @return [String] a bootstrap-based button dropdown menu
  def state_change_links(machine)
    trans_path = resource_path + "/state_transitions/new.js?state_transition[state_event]="
    links = machine.state_events.map do |event|
      next unless can? event, machine
      link_to(t("activerecord.state_machines.events.#{event}").titleize, trans_path + event.to_s, :remote => true)
    end.compact
    # Add cancel link
    if can? :cancel, machine
      links << ""
      links << link_to(t("helpers.links.cancel"), "#{trans_path}cancel", :remote => true)
    end
    # Add adjust_state link
    if can? :adjust_state, machine
      links << ""
      links << link_to(t("helpers.links.adjust_state"), resource_path + "/state_adjustments/new.js", :remote => true)
    end
    dropdown t("helpers.workflow_actions"), links
  end

  # Outputs a Bootstrap's button dropdown menu
  #
  # @param [String]  label  the title of the button
  # @param [Array]  links  list of options for the dropdown. Empty strings are
  #   considered dividers
  # @return [String] a btn-group div
  def dropdown(label, links)
    if links.empty?
      ""
    else
      li_tags = links.map do |l|
        if l.empty?
          content_tag(:li, "", :class => "divider")
        else
          content_tag(:li, l)
        end
      end
      content_tag(:div,
        link_to(label.html_safe + " " + content_tag(:span, "", class: "caret"),
          "#",
          class: "btn dropdown-toggle", data: {toggle: "dropdown"}) +
        content_tag(:ul, li_tags.join("\n").html_safe, class: "dropdown-menu"),
        class: "btn-group")
    end
  end

  # URL for accesing to a given request or reimbursement
  #
  # This helper deals with the singleton issues in the reimbursement routes
  # definition.
  def machine_url(machine)
    if machine.kind_of?(Reimbursement)
      request_reimbursement_url(machine.request)
    else
      send(:"#{machine.class.model_name.element}_url", machine)
    end
  end

  # Path to the list of requests or reimbursements with the ransack filters
  # already configured based on the assign_state definitions of the
  # corresponding class.
  #
  # @see HasState.assign_state
  def menu_path_to(machine_class)
    helper = machine_class.model_name.to_s.tableize + "_path"
    # Assistants are a special case, they should have the same default filters than tsp
    role = current_role.to_s == "assistant" ? :tsp : current_role
    states = machine_class.states_assigned_to(role)
    # FIXME: requesters are also an special case nowadays. Let's look for a
    # better solution afterward.
    if current_role?(:none) || states.blank?
      send helper
    else
      send(helper, :q => {:state_in => states})
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

      type = "success" if type == "notice"
      type = "error" if type == "alert"
      next unless %w(error info success warning).include?(type)

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
  # @param [Event]  event  An optional event in which context the currency is
  #            going to be defined. Only relevant if budget_limits are enabled.
  # @return [Array]  Array with the currency codes
  def currencies_for_select(field, event = nil)
    if TravelSupport::Config.setting(:budget_limits) &&
          event && event.budget && event.budget.currency &&
          %w(approved authorized).include?(field.to_s)
      currencies = [event.budget.currency]
    end
    currencies ||= TravelSupport::Config.setting("currencies_for_#{field}")
    currencies ||= I18n.translate(:currencies).keys.sort
  end

  # Image to be used as header in pdf files
  #
  # @return [String] local path of the image
  def pdf_header_image
    if theme = TravelSupport::Config.setting(:theme)
      path = File.join(Rails.root.to_s, 'app', 'themes', theme, 'assets', 'images', 'pdf', 'header.png')
      return path if File.exists?(path)
    end
    File.join(Rails.root.to_s, 'app', 'assets', 'images', 'pdf', 'header.png')
  end

  # Checks if the current user logged in using iChain
  #
  # @return [Boolean] true if signed in by means of iChain
  def user_signed_in_by_ichain?
    return false unless user_signed_in?
    current_user.respond_to?(:signed_in_by_ichain?) && current_user.signed_in_by_ichain?
  end

  # Outputs the breadcrumbs based in the @breadcrumbs variable
  #
  # @return [String] unordered list containing the breadcrumbs
  def breadcrumbs
    return "" unless @breadcrumbs and @breadcrumbs.respond_to?(:map)
    crumbs = @breadcrumbs.map do |b|
      # First of all, adjust the label,...
      label = b[:label]
      # ...that can be a string, but...
      unless label.kind_of? String
        # ...also a symbol...
        if label.kind_of? Symbol
          label = I18n.t(label)
        # ...or a more complex object.
        # In that case, some methods are tried before
        # falling back to 'classname #id'
        elsif label.respond_to? :name
          label = label.name
        elsif label.respond_to? :title
          label = label.title
        else
          label = "#{label.class.model_name.human} ##{label.id}"
        end
      end

      if b[:url].blank? || current_page?(b[:url])
        content_tag(:li, label, :class => "active")
      else
        content_tag(:li, link_to(label, b[:url]))
      end
    end

    crumbs = crumbs.join(" " + content_tag(:span, ">", :class => "divider") + " ")
    content_tag(:ul, crumbs.html_safe, :class => "breadcrumb")
  end
end
