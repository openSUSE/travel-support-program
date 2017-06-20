class BudgetsController < InheritedResources::Base
  respond_to :html, :json
  skip_load_resource only: [:index, :new]

  protected

  def collection
    @q ||= end_of_association_chain.accessible_by(current_ability).search(params[:q])
    @q.sorts = 'name asc' if @q.sorts.empty?
    @budgets ||= @q.result(distinct: true).page(params[:page]).per(20)
  end

  def permitted_params
    params.permit(budget: [:name, :description, :amount, :currency, event_ids: []])
  end
end
