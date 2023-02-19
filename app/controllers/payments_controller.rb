# frozen_string_literal: true

class PaymentsController < ApplicationController
  authorize_resource :request
  authorize_resource :reimbursement, through: :request, singleton: true
  authorize_resource through: :request
  skip_authorize_resource only: :file
  prepend_before_action :set_request
  before_action :set_reimbursement
  before_action :set_payment, only: %i[edit update destroy file]

  before_action :load_methods, except: :file

  def new
    @payment = Payment.new
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.reimbursement = @reimbursement

    respond_to do |format|
      if @payment.save
        format.html { redirect_to request_reimbursement_url(@request), notice: t(:payment_create) }
        format.json { render :show, status: :created, location: @reimbursement }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to request_reimbursement_url(@request), notice: t(:payment_update) }
        format.json { render :show, status: :updated, location: @payment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to request_reimbursement_url(@request), notice: t(:payment_destroyed) }
      format.json { head :no_content }
    end
  end

  def file
    authorize! :update, @payment
    send_file @payment.file.path
  end

  protected

  def load_methods
    @methods = Rails.configuration.site['payment_methods']
  end

  def set_breadcrumbs
    @breadcrumbs = [label: @request, url: @request]
    @breadcrumbs << { label: Reimbursement.model_name.human,
                      url: request_reimbursement_path(request: @request) }
    @breadcrumbs << { label: Payment.model_name.human(count: 2) }
  end

  private

  def set_request
    @request = Request.find(params[:request_id])

    redirect_back(fallback_location: requests_url) unless @request
  end

  def set_reimbursement
    @reimbursement = @request.reimbursement

    redirect_back(fallback_location: reimbursements_url) unless @reimbursement
  end

  def set_payment
    @payment = Payment.find(params[:id])

    redirect_back(fallback_location: request_reimbursement_url(@request)) unless @payment
  end

  def payment_params
    payment = %i[date amount currency cost_amount cost_currency method code subject notes file file_cache]
    params.require(:payment).permit(payment)
  end
end
