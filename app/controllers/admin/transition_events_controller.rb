class Admin::TransitionEventsController < InheritedResources::Base
  respond_to :html, :json
  skip_load_resource :only => [:index, :new]
  before_action :clean_allowed_roles, only: [:create,:update]
	
  def create
    @transition_event ||= TransitionEvent.new(params[:transition_event])
    @transition_event.user = current_user
    create!
  end

  protected

  def collection
    @q ||= end_of_association_chain.accessible_by(current_ability).search(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?
    @transition_events ||= @q.result(:distinct => true).page(params[:page]).per(20)
  end

  def permitted_params
    params.permit(:transition_event => [:name, :machine_type, :user_id, :description,
                                        {:source_state_ids => []}, :target_state_id, {:allowed_roles => []}])
  end

  # a method to clean the content of params to suit table in db
  def clean_allowed_roles
    temp_arr=params[:transition_event][:allowed_roles].map(&:to_i)
    temp_arr.delete(0)
    params[:transition_event][:allowed_roles]=temp_arr
  end
end
