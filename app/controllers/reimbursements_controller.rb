# frozen_string_literal: true

class ReimbursementsController < ApplicationController
  authorize_resource :request, except: %i[index check_request]
  authorize_resource :reimbursement, through: :request, singleton: true, except: %i[index create check_request]
  skip_authorize_resource only: %i[index check_request]
  skip_load_resource
  helper_method :reimbursement_states_collection
  prepend_before_action :set_reimbursement, only: %i[show edit update destroy]
  prepend_before_action :set_request, except: %i[index check_request]

  def index
    @q ||= Reimbursement.accessible_by(current_ability).includes(request: :expenses).ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty?
    @all_reimbursements ||= @q.result(distinct: true)
    @index ||= @all_reimbursements.page(params[:page]).per(20)
  end

  def show; end

  def new
    @reimbursement = Reimbursement.new
  end

  def create
    redirect_to edit_reimbursement_path(@request.reimbursement) unless @request.reimbursement.nil? || @request.reimbursement.new_record?
    @reimbursement = Reimbursement.new
    @reimbursement.request = @request

    respond_to do |format|
      if @reimbursement.save
        format.html { redirect_to edit_request_reimbursement_url(@request), notice: t(:reimbursement_create) }
        format.json { render :show, status: :created, location: @reimbursement }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reimbursement.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @reimbursement.update(reimbursement_params)
        format.html { redirect_to request_reimbursement_url(@request), notice: t(:reimbursement_update) }
        format.json { render :show, status: :updated, location: @reimbursement }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reimbursement.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @reimbursement.destroy

    respond_to do |format|
      format.html { redirect_to request_url(@request), notice: t(:reimbursement_destroyed) }
      format.json { head :no_content }
    end
  end

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

  private

  def reimbursement_states_collection
    Reimbursement.state_machines[:state].states.map { |s| [s.human_name, s.value] }
  end

  def set_breadcrumbs
    @breadcrumbs = action_name == 'index' ? [label: Reimbursement.model_name.human] : [label: @request, url: @request]
    @breadcrumbs << { label: Reimbursement.model_name.human, url: request_reimbursement_path(@request) } unless @reimbursement.blank? || @reimbursement.new_record?
  end

  def set_request
    @request = Request.find(params[:request_id])

    redirect_back(fallback_location: requests_url) unless @request
  end

  def set_reimbursement
    @reimbursement = @request.reimbursement

    redirect_back(fallback_location: reimbursements_url) unless @reimbursement
  end

  def reimbursement_params
    bank_account_attributes = %i[holder bank_name iban bic national_bank_code format national_account_code country_code bank_postal_address]
    params.require(:reimbursement).permit(:description,
                                          request_attributes: [expenses_attributes: %i[id total_amount authorized_amount]],
                                          attachments_attributes: %i[id title file file_cache _destroy],
                                          links_attributes: %i[id title url _destroy],
                                          bank_account_attributes: bank_account_attributes)
  end
end
