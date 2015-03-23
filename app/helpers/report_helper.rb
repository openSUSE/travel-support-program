#
# Helpers for generating expenses reports
#
module ReportHelper
  # Outputs a dropdown for filtering the expenses report with a given scope
  def filter_select(name, collection, value_method = :id, text_method = :name)
    value = @filter && @filter[name]
    options = content_tag(:option, t(:expenses_report_all), :value => "")
    options << options_from_collection_for_select(collection, value_method, text_method, value)
    select_tag "filter[#{name}]", options
  end

  # Outputs a date picker for filtering the expenses report with a given scope
  def filter_datepicker(name)
     value = @filter && @filter[name]
     data = {"date-autoclose" => true, "date-format" => "yyyy-mm-dd", "date-language" => I18n.locale.to_s}
     text_field_tag "filter[#{name}]", value, :class => "date-without-time dpicker", :data => data
  end

  # Outputs a text input for filtering the expenses report with a given scope
  def filter_text_field(name)
    value = @filter && @filter[name]
    text_field_tag "filter[#{name}]", value
  end

  # Outputs the html representation of the field for a given
  # TravelExpenseReport instance.
  #
  # @param [#to_sym] field name of the field
  # @param [TravelExpenseReport] expense the instance
  # @return HTML output
  def html_value_for(field, expense)
    if respond_to? :"html_value_for_#{field}"
      send(:"html_value_for_#{field}", expense)
    elsif respond_to? :"value_for_#{field}"
      send(:"value_for_#{field}", expense)
    else
      expense.value_for field
    end
  end

  # Return the value of a field for a given TravelExpenseReport
  # instance, in a format useful to the axlsx template.
  #
  # @param [#to_sym] field name of the field
  # @param [TravelExpenseReport] expense the instance
  # @return [Object] value for the template
  def xlsx_value_for(field, expense)
    if respond_to? :"xlsx_value_for_#{field}"
      send(:"xlsx_value_for_#{field}", expense)
    elsif respond_to? :"value_for_#{field}"
      send(:"value_for_#{field}", expense)
    else
      expense.value_for field
    end
  end

  # Called from html_value_for and xlsx_value_for
  # @see #html_value_for
  # @see #xlsx_value_for
  def value_for_request_state(expense)
    TravelSponsorship.human_state_name expense.value_for(:request_state)
  end

  # Called from html_value_for
  # @see #html_value_for
  def html_value_for_reimbursement_state(expense)
    state = expense.value_for(:reimbursement_state)
    if state.blank?
      ""
    else
      state = Reimbursement.human_state_name(state)
      link_to(state, request_reimbursement_path(expense[:request_id]))
    end
  end

  # Called from xlsx_value_for
  # @see #xlsx_value_for
  def xslx_value_for_reimbursement_state(expense)
    state = expense.value_for(:reimbursement_state)
    state.blank? ? "" : Reimbursement.human_state_name(state)
  end

  # Called from html_value_for
  # @see #html_value_for
  def html_value_for_event_name(expense)
    link_to expense[:event_name], event_path(expense[:event_id])
  end

  # Called from html_value_for
  # @see #html_value_for
  def html_value_for_request_id(expense)
    link_to "##{expense[:request_id]}", request_path(expense[:request_id])
  end

  # Called from html_value_for
  # @see #html_value_for
  def html_value_for_sum_amount(expense)
    number_to_currency(expense.value_for(:sum_amount) || 0, :unit => "")
  end

  # Called from html_value_for
  # @see #html_value_for
  def html_value_for_event_country(expense)
    content_tag(:span, expense[:event_country], :title => t("countries.#{expense[:event_country]}"))
  end

  # Called from html_value_for
  # @see #html_value_for
  def html_value_for_user_country(expense)
    content_tag(:span, expense[:user_country], :title => t("countries.#{expense[:user_country]}"))
  end

  # Called from html_value_for
  # @see #html_value_for
  def html_value_for_event_start_date(expense)
    l(expense.value_for(:event_start_date))
  end

  # Called from html_value_for
  # @see #html_value_for
  def html_value_for_event_end_date(expense)
    l(expense.value_for(:event_end_date))
  end

  # Called from xlsx_value_for
  # @see #xlsx_value_for
  def xlsx_value_for_user_country(expense)
    country_label(expense.value_for(:user_country))
  end

  # Called from xlsx_value_for
  # @see #xlsx_value_for
  def xlsx_value_for_event_country(expense)
    country_label(expense.value_for(:event_country))
  end

  # Style for the axlsx template for a given field
  #
  # @param [#to_sym] field name of the field
  # @return [Hash] Style definition, nil if no special style is defined
  def xlsx_style_for(field)
    if respond_to? :"xlsx_style_for_#{field}"
      send(:"xlsx_style_for_#{field}")
    else
      nil
    end
  end

  # Called from xlsx_style_for
  # @see #xlsx_style_for
  def xlsx_style_for_sum_amount
    {:num_fmt => 2}
  end
end
