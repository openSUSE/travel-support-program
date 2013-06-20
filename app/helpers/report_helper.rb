module ReportHelper
  def filter_select(name, collection, value_method = :id, text_method = :name)
    value = @filter && @filter[name]
    options = content_tag(:option, t(:expenses_report_all), :value => "")
    options << options_from_collection_for_select(collection, value_method, text_method, value)
    select_tag "filter[#{name}]", options
  end

  def filter_datepicker(name)
     value = @filter && @filter[name]
     data = {"date-autoclose" => true, "date-format" => "yyyy-mm-dd", "date-language" => I18n.locale.to_s}
     text_field_tag "filter[#{name}]", value, :class => "date-without-time dpicker", :data => data
  end

  def filter_text_field(name)
    value = @filter && @filter[name]
    text_field_tag "filter[#{name}]", value
  end

  def value_for(field, expense)
    if respond_to? :"value_for_#{field}"
      send(:"value_for_#{field}", expense)
    else
      expense[field]
    end
  end

  def value_for_event_name(expense)
    link_to expense[:event_name], event_path(expense[:event_id])
  end

  def value_for_request_id(expense)
    link_to "##{expense[:request_id]}", request_path(expense[:request_id])
  end

  def value_for_request_state(expense)
    Request.human_state_name(expense[:request_state])
  end

  def value_for_reimbursement_id(expense)
    id = expense[:reimbursement_id]
    id.blank? ? "" : link_to("##{id}", request_reimbursement_path(expense[:request_id]))
  end

  def value_for_reimbursement_state(expense)
    state = expense[:reimbursement_state]
    state.blank? ? "" : Reimbursement.human_state_name(state)
  end

  def value_for_sum_amount(expense)
    number_to_currency(expense[:sum_amount], :unit => "")
  end

  def value_for_event_country(expense)
    content_tag(:span, expense[:event_country], :title => t("countries.#{expense[:event_country]}"))
  end

  def value_for_user_country(expense)
    content_tag(:span, expense[:user_country], :title => t("countries.#{expense[:user_country]}"))
  end
end
