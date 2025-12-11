# frozen_string_literal: true

class ShipmentsController < ApplicationController
  skip_load_resource only: %i[index new]
  before_action :set_states_collection, only: [:index]
  before_action :set_event, only: [:new]
  before_action :set_shipment, only: %i[show edit update destroy]

  def index
    @q ||= Shipment.accessible_by(current_ability).ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty?
    @all_shipments ||= @q.result(distinct: true)
    @index ||= @all_shipments.page(params[:page]).per(20)
  end

  def show; end

  def new
    @shipment = Shipment.new
    @shipment.event = @event
    @shipment.user = current_user
    @shipment.populate_contact_info
    authorize! :create, @shipment
  end

  def create
    @shipment = Shipment.new(shipment_params)
    @shipment.user = current_user

    respond_to do |format|
      if @shipment.save
        format.html { redirect_to shipment_url(@shipment), notice: t(:shipment_create) }
        format.json { render :show, status: :created, location: @shipment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @shipment.update(shipment_params)
        format.html { redirect_to shipment_url(@shipment), notice: t(:shipment_update) }
        format.json { render :show, status: :updated, location: @shipment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @shipment.destroy

    respond_to do |format|
      format.html { redirect_to shipments_url, notice: t(:shipment_destroyed) }
      format.json { head :no_content }
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])

    redirect_back(fallback_location: events_url) unless @event
  end

  def set_shipment
    @shipment = Shipment.find(params[:id])

    redirect_back(fallback_location: shipments_url) unless @shipment
  end

  def set_states_collection
    @states_collection = Shipment.state_machines[:state].states.map { |s| [s.human_name, s.value] }
  end

  def shipment_params
    postal_address_attributes = %i[line1 line2 city county postal_code country_code]
    params.require(:shipment).permit(:event_id, :description, :contact_phone_number, postal_address_attributes: postal_address_attributes)
  end
end
