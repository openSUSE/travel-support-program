# frozen_string_literal: true

class CheckRequestPdf
  def self.render(template:, layout:, &value)
    document = HexaPDF::Document.open(template.to_s)
    overlay = Prawn::Document.new(skip_page_creation: true)
    layout.fetch('pages').each_with_index do |page, index|
      template_page = document.pages[index]
      raise ArgumentError, 'Check request layout has more pages than its template' unless template_page

      overlay.start_new_page(size: [template_page.box.width, template_page.box.height])
      page.fetch('fields').each { |field| draw_field(overlay, field, page, value) }
    end

    # Modify the original pages so template graphics, links, and annotations survive.
    overlay_document = HexaPDF::Document.new(io: StringIO.new(overlay.render))
    overlay_document.pages.each_with_index do |page, index|
      form = document.import(page.to_form_xobject)
      document.pages[index].canvas(type: :overlay).xobject(form, at: [0, 0])
    end
    output = StringIO.new
    document.write(output)
    output.string
  end

  def self.draw_field(pdf, field, page, value)
    locations = field.fetch('location')
    locations = [locations] unless locations.is_a?(Array)
    content = value.call(field.fetch('name')).to_s
    locations.each do |location|
      upcase = location['upcase']
      upcase = page['upcase'] if upcase.nil?
      pdf.bounding_box([location.fetch('left'), location.fetch('top')], width: location.fetch('width')) do
        pdf.text(upcase ? content.upcase : content,
                 size: location['text_size'] || page['text_size'] || 12,
                 leading: location['line_space'] || page['line_space'] || 0)
      end
    end
  end
  private_class_method :draw_field
end
