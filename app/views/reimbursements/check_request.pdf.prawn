prawn_document :template => @template do |pdf|

  @fields.each do |field, location|
    locations = location.kind_of?(Array) ? location : [location]
    locations.each do |loc|
      pdf.bounding_box [loc["left"], loc["top"]], :width => loc["width"] do
        pdf.text check_request_value(@reimbursement, field), :size => 10
      end
    end
  end
end
