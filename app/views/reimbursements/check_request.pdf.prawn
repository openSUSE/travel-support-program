def print_field(pdf, field, page)
  location = field["location"]
  locations = location.kind_of?(Array) ? location : [location]

  locations.each do |loc|
    content = check_request_value(@reimbursement, field["name"]) || ""
    upcase = loc["upcase"]
    upcase = page["upcase"] if upcase.nil?

    pdf.bounding_box [loc["left"], loc["top"]], :width => loc["width"] do
      pdf.text(upcase ? content.upcase : content,
               :size => loc["text_size"] || page["text_size"],
               :leading => loc["line_space"] || page["line_space"])
    end
  end
end

prawn_document :template => @template do |pdf|

  @fields["pages"].each_with_index do |page, idx|
    pdf.go_to_page idx+1

    page["fields"].each do |field, location|
      print_field(pdf, field, page)
    end
  end
end
