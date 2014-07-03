class Admin::StatesController < InheritedResources::Base
  respond_to :html, :json
  skip_load_resource :only => [:index, :new]
	
  def create
    @state ||= State.new(params[:state])
    @state.user = current_user
    create!
  end

  protected

  def collection
    @q ||= end_of_association_chain.accessible_by(current_ability).search(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?
    @states ||= @q.result(:distinct => true).page(params[:page]).per(20)
  end

  def permitted_params
    params.permit(:state=> [:name, :machine_type, :user_id, :temp_comments, :description, :role_id, :initial_state])
  end
end
