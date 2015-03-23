#
# Custom simple_form input type for integration with bootstrap-datetimepicker
#
# To use it, simply add :as => :dpicker to your input and it will automatically
# deal with all the I18n issues, making automatic conversion from Rails I18n
# formats to the one expected by bootstrap-datetimepicker.
#
# With no options, it behaves as a date only widget (you must call
# datetimepicker javascript method with minView option set to 2) and add the
# date-without-time css class to the widget.
#
# With :with_time => true, support for time selection and a date-with-time css
# class will be added.
#
# Of course, it only fixes the view issues, you still have to take care of
# date parsing on the controller.
#
# See http://www.malot.fr/bootstrap-datetimepicker/ for acceptable date formats
#
class DpickerInput < SimpleForm::Inputs::StringInput

  def input(wrapper_options={})
    input_html_options[:size]      ||= [limit, SimpleForm.default_input_size].compact.min
    input_html_options[:maxlength] ||= limit if limit
    input_html_options[:type]      ||= "text"
    input_html_options["data-date-autoclose"] = true

    format = options[:format] || :default

    if options[:value]
      value = options[:value]
    elsif object.send(attribute_name) 
      value = object.send(attribute_name)
    else
      value = nil
    end
    if options[:with_time]
      input_html_options["data-date-format"] = js_format(I18n.t("time.formats.#{format}"))
    else
      input_html_options["data-date-format"] = js_format(I18n.t("date.formats.#{format}"))
      value = value.to_date unless value.blank?
    end
    input_html_options[:value] = I18n.l(value, :format => format) unless value.blank?

    if lang = options[:language]
      input_html_options["data-date-language"] = lang
    elsif lang = I18n.locale.to_s
      input_html_options["data-date-language"] = lang
    end

    input_html_options["data-date-weekstart"] = options[:week_start] if options[:week_start]
    input_html_options["data-date-startDate"] = I18n.l(options[:start_date].to_date, :format => format) if options[:start_date]
    input_html_options["data-date-endDate"] =  I18n.l(options[:end_date].to_date, :format => format) if options[:end_date]
    input_html_options["data-date-autoclose"] = options[:autoclose] if options[:autoclose]
    #input_html_options["data-date-startView"] = options[:start_view] if options[:start_view]

    @builder.text_field(attribute_name, input_html_options)
  end

  def input_html_classes
    if options[:with_time]
      super.unshift("datepicker", "date-with-time")
    else
      super.unshift("datepicker", "date-without-time")
    end
  end

  protected

  def js_format(format)
    out = format.gsub("%M","ii").gsub("%S","ss").gsub("%p","P").gsub("%P","p")
    out = out.gsub("%k","h").gsub("%H","hh").gsub("%l","H").gsub("%I","HH")
    out = out.gsub("%-d","d").gsub("%d","dd").gsub("%a","D").gsub("%A","DD")
    out = out.gsub("%-m","m").gsub("%m","mm").gsub("%b","M").gsub("%B","MM")
    out.gsub("%y","yy").gsub("%Y","yyyy")
  end

end
