class ReportsController < ApplicationController
  skip_load_and_authorize_resource

  def expenses
    @by_type_options = %w(estimated approved total authorized)
    @by_group_options = ExpenseReport.groups.map(&:to_s)
    #@events = Event.order(:name)
    @request_states = Request.state_machines[:state].states.map {|s| [ s.value, s.human_name] }
    @reimbursement_states = Reimbursement.state_machines[:state].states.map {|s| [ s.value, s.human_name] }
    @countries = I18n.t(:countries).map {|k,v| [k.to_s,v]}.sort_by(&:last)

    @filter = params[:filter]
    if (@type = params[:by_type]) && (@group = params[:by_group])
      @expenses = ExpenseReport.by(@type, @group).accessible_by(current_ability)
      if @filter
        @filter.each { |k,v| @expenses = @expenses.send(k, v) unless v.blank? }
      end
      @expenses = @expenses.order(:sum_amount).page(params[:page] || 1).per(20)
    else
      @expenses = []
    end
  end
end
