class ExpensesApprovalsController < ApplicationController
  respond_to :html, :json
  skip_load_and_authorize_resource
  before_filter :load_request_and_authorize

  def update
    if p = params[:expenses_approval]
      @request.expenses.each do |expense|
        expense.approved_amount = p[:"amount_#{expense.id}"]
        expense.approved_currency = p[:"currency_#{expense.id}"]
        expense.save
      end
    end
    respond_to do |format|
      format.html do
        redirect_to @request,
                    notice: I18n.t(:"flash.actions.update.notice", resource_name: 'request')
      end
      format.json { render json: { request: @request } }
    end
  end

  protected

  def load_request_and_authorize
    @request = TravelSponsorship.includes(:expenses).find(params[:travel_sponsorship_id])
    authorize! :approve, @request
  end
end
