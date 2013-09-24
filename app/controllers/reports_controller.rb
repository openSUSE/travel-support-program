class ReportsController < ApplicationController
  skip_load_and_authorize_resource

  def expenses
    @filter = params[:filter]
    if (@type = params[:by_type]) && (@group = params[:by_group])
      @expenses = ExpenseReport.by(@type, @group).accessible_by(current_ability)
      if @filter
        @filter.each { |k,v| @expenses = @expenses.send(k, v) unless v.blank? }
      end
      @expenses = @expenses.order("sum_amount desc")
      respond_to do |format|
        format.html {
          init_form
          @expenses = @expenses.page(params[:page] || 1).per(20)
        }
        format.xlsx { render :xlsx => "expenses", :disposition => "attachment", :filename => "expenses.xlsx" }
      end
    else
      respond_to do |format|
        format.html { init_form }
        format.xlsx { redirect_to expenses_report_path(:format => :html) }
      end
    end
  end

  protected

  def init_form
    @by_type_options = %w(estimated approved total authorized)
    @by_group_options = ExpenseReport.groups.map(&:to_s)
    #@events = Event.order(:name)
    @request_states = Request.state_machines[:state].states.map {|s| [ s.value, s.human_name] }
    @reimbursement_states = Reimbursement.state_machines[:state].states.map {|s| [ s.value, s.human_name] }
    @countries = I18n.t(:countries).map {|k,v| [k.to_s,v]}.sort_by(&:last)
  end

  def set_breadcrumbs
    @breadcrumbs = [{:label => :breadcrumb_reports}]
  end
end
