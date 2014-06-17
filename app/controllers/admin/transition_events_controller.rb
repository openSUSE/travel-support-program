class Admin::TransitionEventsController < InheritedResources::Base
	respond_to :html, :json
	skip_load_resource :only => [:index, :new]

	
	def create
		@transition_event ||= TransitionEvent.new(params[:transition_event])
		@transition_event.user = current_user
		if @transition_event.valid_transition?
			create!
		else
			flash[:notice]="This is an invalid transition"
			redirect_to new_resource_url
		end
	end

	protected

	def collection
		@q ||= end_of_association_chain.accessible_by(current_ability).search(params[:q])
		@q.sorts = "name asc" if @q.sorts.empty?
		@transition_events ||= @q.result(:distinct => true).page(params[:page]).per(20)
	end
end
