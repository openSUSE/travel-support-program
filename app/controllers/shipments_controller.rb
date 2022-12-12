# frozen_string_literal: true

class ShipmentsController < InheritedResources::Base
  respond_to :html, :js, :json
  skip_load_resource only: %i[index new]
  before_action :set_states_collection, only: [:index]

  def show; end

  def create
    @shipment ||= Shipment.new(params[:shipment])
    @shipment.user = current_user
    create!
  end

  def new
    @shipment ||= Shipment.new(params[:shipment])
    @shipment.event = Event.find(params[:event_id])
    @shipment.user = current_user
    @shipment.populate_contact_info
    authorize! :create, @shipment
    new!
  end

  protected

  def collection
    @q ||= end_of_association_chain.accessible_by(current_ability).ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty?
    @all_shipments ||= @q.result(distinct: true)
    @shipments ||= @all_shipments.page(params[:page]).per(20)
  end

  def set_states_collection
    @states_collection = Shipment.state_machines[:state].states.map { |s| [s.human_name, s.value] }
  end

  def permitted_params
    postal_address_attributes = %i[line1 line2 city county postal_code country_code]
    params.permit(shipment: [:event_id, :description, :contact_phone_number, postal_address_attributes: postal_address_attributes])
  end
end
