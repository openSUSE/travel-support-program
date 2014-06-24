class ShipmentsController < InheritedResources::Base
  respond_to :html, :js, :json
  skip_load_resource :only => [:index, :new]
  before_filter :set_states_collection, :only => [:index]

  def show
    # We don't want to break the normal process if something goes wrong
    resource.user.profile.refresh rescue nil
    show!
  end

  def create
    @shipment ||= Shipment.new(params[:shipment])
    @shipment.user = current_user
    create!
  end

  def new
    @shipment ||= Shipment.new(params[:shipment])
    @shipment.event = Event.find(params[:event_id])
    @shipment.user = current_user
    authorize! :create, @shipment
    new!
  end

  protected

  def collection
    @q ||= end_of_association_chain.accessible_by(current_ability).search(params[:q])
    @q.sorts = "id asc" if @q.sorts.empty?
    @all_shipments ||= @q.result(:distinct => true)
    @shipments ||= @all_shipments.page(params[:page]).per(20)
  end

  def set_states_collection
    @states_collection = Shipment.state_machines[:state].states.map {|s| [ s.human_name, s.value] }
  end

  def permitted_params
    params.permit(:shipment => [:event_id, :description, :delivery_address])
  end
end
