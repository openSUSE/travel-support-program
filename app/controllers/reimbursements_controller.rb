class ReimbursementsController < InheritedResources::Base
  respond_to :html, :js, :json, :pdf
  load_and_authorize_resource :request, :except => [:check_request]
  load_and_authorize_resource :reimbursement, :through => :request, :singleton => true, :except => [:create, :check_request]
  skip_load_and_authorize_resource :only => :check_request

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
    @reimbursement = Reimbursement.where(:request_id => params[:request_id]).includes(:user => :profile).first

    # Probably, this is not the most obvious choice, but makes some sense:
    # only users who can create payments can print the check request
    authorize! :read, @reimbursement
    authorize! :create, @reimbursement.payments.build

    c_template = TravelSupportProgram::Config.setting(:check_request_template)
    c_layout = TravelSupportProgram::Config.setting(:check_request_layout)
    if c_template.blank? or c_layout.blank?
      redirect_to request_reimbursement_path(@reimbursement.request)
    else
      @template = Rails.root.join("config", c_template)
      @layout = Rails.root.join("config", c_layout)
      @fields = YAML.load_file(@layout)
    end
  end
end
