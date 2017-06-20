class ReimbursementAcceptancesController < ApplicationController
  respond_to :html, :js, :json
  skip_load_and_authorize_resource
  before_filter :load_reimbursement_and_authorize, except: :show

  def create
    if params[:acceptance]
      @reimbursement.acceptance_file = params[:acceptance][:file]
      success = @reimbursement.save
    else
      success = false
    end
    respond_to do |format|
      if success
        flash[:notice] = I18n.t(:reimbursement_acceptance_success)
        format.json { render json: { file: @reimbursement.file.to_s }, status: :created }
      else
        flash[:error] = I18n.t(:reimbursement_acceptance_failure)
        unless @reimbursement.errors.empty?
          flash[:error] << "\n<br/>" + @reimbursement.errors.full_messages.map { |i| i.humanize + '.' }.join(' ')
        end
        format.json { render json: @reimbursement.errors, status: :unprocessable_entity }
      end
      location = request_reimbursement_path(@request)
      format.html { redirect_to location }
    end
  end

  def show
    load_reimbursement
    authorize! :read, @reimbursement
    send_file @reimbursement.acceptance_file.path
  end

  protected

  def load_reimbursement
    @request = Request.find(params[:request_id])
    @reimbursement = @request.reimbursement
  end

  def load_reimbursement_and_authorize
    load_reimbursement
    authorize! :submit, @reimbursement
  end
end
