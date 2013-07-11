class ReimbursementsController < InheritedResources::Base
  respond_to :html, :js, :json, :pdf
  load_and_authorize_resource :request, :except => [:check_request]
  load_and_authorize_resource :reimbursement, :through => :request, :singleton => true, :except => [:create, :check_request]
  skip_authorize_resource :only => :check_request

  defaults :singleton => true
  belongs_to :request

  def create
    if parent.reimbursement.nil? || parent.reimbursement.new_record?
      @reimbursement = Reimbursement.new
      @reimbursement.request = parent
      create! {edit_resource_path}
    else
      redirect_to edit_resource_path
    end
  end

  def show
    # We don't want to break the normal process if something goes wrong
    resource.user.profile.refresh rescue nil
    show!
  end

  def check_request
    # Probably, this is not the most obvious choice, but makes some sense:
    # only users who can create payments can print the check request
    authorize! :create, resource.payments.build

    p = resource.user.profile
    values = {
      :amount => self.class.helpers.expenses_sum(resource, :authorized),
      :name => escaped(p.full_name),
      :date => I18n.l(Date.today),
      :address => escaped(p.postal_address),
      :city => escaped(p.location),
      :state => self.class.helpers.country_label(p.country_code),
      :zipcode => escaped(p.zip_code),
      :phone => escaped(p.phone_number) }

    fdf = "%FDF-1.2\n1 0 obj<</FDF<< /Fields[\n"
    fdf << values.map { |k,v| "<</T(#{k})/V(#{v})>>" }.join("\n")
    fdf << "\n] >> >>\nendobj\ntrailer\n<</Root 1 0 R>>\n%%EOF"
    # pdftk does not support utf-8 when filling forms
    if fdf.respond_to?(:encode!)
      # Ruby >= 1.9
      fdf.encode!('ISO-8859-15', :invalid => :replace, :undef => :replace)
    else
      # pre 1.9
      require 'iconv'
      fdf = Iconv.conv('ISO-8859-15//IGNORE', 'utf-8', fdf)
    end

    begin
      fdf_file = Tempfile.new('fdf', Rails.root.join('tmp'), :encoding => 'ISO-8859-15')
      fdf_file << fdf
      fdf_file.flush

      pdftk = TravelSupportProgram::Config.setting :pdftk_path
      template = Rails.root.join(TravelSupportProgram::Config.setting(:check_request_template))
      send_data %x{pdftk #{template} fill_form #{fdf_file.path} output -},
        :filename => "checkrequest#{resource.id}.pdf"#, :type => "application/pdf"
    ensure
      fdf_file.close
    end
  end

  private

  # espace parenthesis that are not already escaped
  def escaped(string)
    string.gsub(/([^\\])([\)\(])/, "\\1\\\\\\2")
  end
end
