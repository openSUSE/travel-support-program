class RequestsController < InheritedResources::Base
  respond_to :html, :js, :json
  skip_load_resource :only => [:index]
  helper_method :request_states_collection

  def create
    @request ||= Request.new(params[:request])
    @request.user = current_user
    create!
  end

  def new
    @request ||= Request.new(params[:request])
    @request.event = Event.find(params[:event_id])
    @request.user = current_user
    @request.expenses.build
    new!
  end

  protected

  def collection
    @q ||= end_of_association_chain.accessible_by(current_ability).includes(:expenses).search(params[:q])
    @q.sorts = "id asc" if @q.sorts.empty?
    @requests ||= @q.result(:distinct => true).page(params[:page]).per(20)
  end

  def request_states_collection
    Request.state_machines[:state].states.map {|s| [ s.human_name, s.value] }
  end
end
