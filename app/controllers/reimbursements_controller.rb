class ReimbursementsController < InheritedResources::Base
  respond_to :html, :js, :json, :pdf
  load_and_authorize_resource :request, except: [:check_request]
  load_and_authorize_resource :reimbursement, through: :request, singleton: true, except: %i[create check_request]
  skip_load_and_authorize_resource only: :check_request

  defaults singleton: true
  belongs_to :request

  def create
    if parent.reimbursement.nil? || parent.reimbursement.new_record?
      @reimbursement = Reimbursement.new
      @reimbursement.request = parent
      create! { edit_resource_path }
    else
      redirect_to edit_resource_path
    end
  end

  def show; end

  def check_request
    @reimbursement = Reimbursement.where(request_id: params[:request_id]).includes(user: :profile).first

    # Probably, this is not the most obvious choice, but makes some sense:
    # only users who can create payments can print the check request
    authorize! :read, @reimbursement
    authorize! :create, @reimbursement.payments.build

    c_template = Rails.configuration.site['check_request_template']
    c_layout = Rails.configuration.site['check_request_layout']
    if c_template.blank? || c_layout.blank?
      redirect_to request_reimbursement_path(@reimbursement.request)
    else
      @template = Rails.root.join('config', c_template)
      @layout = Rails.root.join('config', c_layout)
      @fields = YAML.load_file(@layout)
    end
  end

  protected

  def set_breadcrumbs
    @breadcrumbs = [label: parent, url: parent]
    @breadcrumbs << { label: Reimbursement.model_name.human, url: resource_path } unless resource.blank? || resource.new_record?
  end

  def permitted_params
    bank_account_attributes = %i[holder bank_name iban bic national_bank_code format national_account_code country_code bank_postal_address]
    params.permit(reimbursement: [:description,
                                  { request_attributes: [{ expenses_attributes: %i[id total_amount authorized_amount] }] },
                                  { attachments_attributes: %i[id title file file_cache _destroy] },
                                  { links_attributes: %i[id title url _destroy] },
                                  { bank_account_attributes: bank_account_attributes }])
  end
end
