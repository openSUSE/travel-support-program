class RequestsController < InheritedResources::Base
  respond_to :html, :js, :json
  skip_load_resource :only => [:index]
  helper_method :request_states_collection

  def create
    @request = Request.new(params[:request])
    @request.user = current_user
    create!
  end

  protected

  def collection
    @q ||= end_of_association_chain.accessible_by(current_ability).search(params[:q])
    @q.sorts = "id asc" if @q.sorts.empty?
    @requests ||= @q.result(:distinct => true).page(params[:page]).per(20)
  end

  def request_states_collection
    Request.state_machines[:state].states.map {|s| [ s.human_name, s.value] }
  end
end
