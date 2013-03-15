class EventsController < InheritedResources::Base
  respond_to :html, :js, :json
  skip_before_filter :authenticate_user!, :only => [:index, :show]
  skip_load_and_authorize_resource :only => [:index, :show]
  before_filter :protect_validation_attributes, :only => [:create, :update]

  protected

  def collection
    @q ||= end_of_association_chain.search(params[:q])
    @q.sorts = "start_date desc" if @q.sorts.empty?
    @requests ||= @q.result(:distinct => true).page(params[:page]).per(20)
  end

  def protect_validation_attributes
    if cannot? :validate, resource
      Event.validation_attributes.each do |att|
        params[:event].delete(att)
      end
    end
  end
end
