#
# Custom simple_form input type for integration with bootstrap-fileupload.js
#
# http://jasny.github.io/bootstrap/javascript.html#fileupload
#
class FileuploadInput < SimpleForm::Inputs::StringInput

  def input
    if object.send("#{attribute_name}?")
      preview = object.send(attribute_name).file.filename
      css = "exists"
    else
      preview = ""
      css = "new"
    end
    input = c_tag(:div,
                        c_tag(:span, preview, :class => "fileupload-preview"),
                        :class => "uneditable-input input-small")
    button = c_tag(:span,
                      c_tag(:span, I18n.t(:fileupload_change), :class => "fileupload-exists") +
                        c_tag(:span, I18n.t(:fileupload_select), :class => "fileupload-new") +
                        @builder.file_field(attribute_name) + @builder.hidden_field("#{attribute_name}_cache"),
                      :class => "btn btn-file")
    c_tag(:div,
                c_tag(:div, input + button, :class => "input-append"),
                :class => "fileupload fileupload-#{css}", :data => {:provides => "fileupload"})
  end

  def c_tag(*args)
    template.content_tag(*args)
  end
end
