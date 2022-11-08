prawn_document :page_size => "A4", :force_download => true do |pdf|
  # First of all, we instantiate some data variables
  
  # For expenses table
  expenses_data = [ [RequestExpense.human_attribute_name(:subject),
                    RequestExpense.human_attribute_name(:description),
                    RequestExpense.human_attribute_name(:authorized_amount) ] ]
  expenses_data += resource.expenses.map do |e|
    [e.subject, e.description, number_to_currency(e.authorized_amount, :unit => e.authorized_currency)]
  end
  expenses_data << [ "", Reimbursement.human_attribute_name(:authorized_sum), expenses_sum(resource, :authorized) ]

  user = resource.user
  profile = user.profile
  # For address table
  address_data = [:postal_address, :zip_code, :location].map do |a|
    [UserProfile.human_attribute_name(a), profile.send(a)]
  end
  address_data << [UserProfile.human_attribute_name(:country), country_label(profile.country_code)]

  # For profile table
  profile_data = [:full_name, :phone_number, :second_phone_number].map do |a|
    [UserProfile.human_attribute_name(a), profile.send(a)]
  end
  profile_data << [User.human_attribute_name(:email), user.email]

  # For event tables
  event = resource.event
  event1_data = [ [Event.human_attribute_name(:name), event.name],
                  [Event.human_attribute_name(:country), country_label(event.country_code) ] ]
  event2_data = [ [Event.human_attribute_name(:start_date), I18n.l(event.start_date, :format => :long)],
                  [Event.human_attribute_name(:end_date), I18n.l(event.end_date, :format => :long) ] ]

  # Bank information
  bank = resource.bank_account
  unless bank.nil? # Should not happen with sane data, anyway
    bank_attributes = [:holder, :bank_name]
    if bank.iban?
      bank_attributes += [:iban, :bic]
    else
      bank_attributes += [:national_account_code, :national_bank_code, :bank_postal_address]
    end
    bank_data = bank_attributes.map {|a| [BankAccount.human_attribute_name(a), bank.send(a)] }
    if bank.national?
      bank_data << [BankAccount.human_attribute_name(:country), country_label(bank.country_code)]
    end
  end

  # Validation warning message
  error_messages = resource.potential_error_full_messages(except: :acceptance_file)
  warning_text = error_messages.map {|m| " - #{m}" }.join("\n")
  unless warning_text.empty?
    warning_text =  I18n.t(:reimbursement_acceptance_warning) + "\n" + warning_text
  end

  # And now, the real layout and formating information
  pdf.font "Helvetica", :size => 9
  pdf.image pdf_header_image, :height => 50, :align => :left
  pdf.move_down(5)
  pdf.stroke_color = "666666"
  pdf.horizontal_rule
  pdf.fill_and_stroke
  pdf.move_down(20)
  pdf.bounding_box [ pdf.bounds.left, pdf.cursor ], :width => 550, :height => 650 do
    pdf.text Rails.configuration.site['program_name'], :size => 16, :style => :bold
    pdf.move_down(10)
    pdf.text "#{resource.title} - #{profile.full_name}", :size => 14, :style => :bold
    # Warning
    pdf.move_down(8)
    unless warning_text.empty?
      warning_height = 6
      pdf.indent 10, 50 do
        warning_height += pdf.height_of_formatted [:text => warning_text]
      end
      pdf.stroke_color "ff0000"
      pdf.stroke do
        pdf.rounded_rectangle [pdf.bounds.left, pdf.cursor], 510, warning_height, 5
      end
      pdf.move_down(4)
      pdf.indent 10, 50 do
        pdf.formatted_text [:text => warning_text]
      end
      pdf.move_down(2)
    end

    # Requester
    pdf.move_down(12)
    pdf.text Reimbursement.human_attribute_name(:user).titleize, :style => :bold, :size => 12
    top = pdf.cursor
    pdf.bounding_box [ pdf.bounds.left, top ], :width => 250 do
      pdf.table profile_data do |t|
        t.column_widths = [70, 180]
        t.cells.borders = []
        t.cells.style(:padding => 2)
        t.columns(0).style :font_style => :bold
      end
    end
    bottom = pdf.cursor
    pdf.bounding_box [ pdf.bounds.left + 260, top ], :width => 270 do
      pdf.table address_data do |t|
        t.column_widths = [50, 220]
        t.cells.borders = []
        t.cells.style(:padding => 2)
        t.columns(0).style :font_style => :bold
      end
    end
    pdf.move_cursor_to [bottom, pdf.cursor].min
    # Event
    pdf.move_down(25)
    pdf.text Reimbursement.human_attribute_name(:event).titleize, :style => :bold, :size => 12
    top = pdf.cursor
    pdf.bounding_box [ pdf.bounds.left, top ], :width => 250 do
      pdf.table event1_data do |t|
        t.column_widths = [70, 180]
        t.cells.borders = []
        t.cells.style(:padding => 2)
        t.columns(0).style :font_style => :bold
      end
    end
    pdf.bounding_box [ pdf.bounds.left + 260, top ], :width => 270 do
      pdf.table event2_data do |t|
        t.column_widths = [50, 220]
        t.cells.borders = []
        t.cells.style(:padding => 2)
        t.columns(0).style :font_style => :bold
      end
    end
    pdf.bounding_box [ pdf.bounds.left, pdf.cursor ], :width => 550 do
      # Expenses
      pdf.move_down(25)
      pdf.text TravelSponsorship.human_attribute_name(:expenses).titleize, :style => :bold, :size => 12
      pdf.table expenses_data do |t|
        t.column_widths = [90, 330, 90]
        t.cells.style(:padding => 3)
        t.cells.borders = []
        t.row(0).style(:font_style => :bold)
        t.row(-1).style(:font_style => :bold)
        t.row(0).borders = [ :bottom ]
        t.columns(2).align = :right
        t.row(-1).columns(1).align = :right
      end

      # Bank account
      unless bank.nil? # Should not happen with sane data, anyway
        pdf.move_down(25)
        pdf.text Reimbursement.human_attribute_name(:bank_account).titleize, :style => :bold, :size => 12
        pdf.table bank_data do |t|
          t.column_widths = [130, 410]
          t.cells.borders = []
          t.cells.style(:padding => 2)
          t.columns(0).style :font_style => :bold
        end
      end

      pdf.move_down(25)
      pdf.text I18n.t(:reimbursement_acceptance_title), :style => :bold, :size => 12
      pdf.move_down(5)
      pdf.text I18n.t(:signature_date), :style => :bold, :size => 10
      pdf.move_down(5)
      pdf.text I18n.t(:signature), :style => :bold, :size => 10
    end
  end
end
