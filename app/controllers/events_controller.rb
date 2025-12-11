# frozen_string_literal: true

class EventsController < ApplicationController
  skip_before_action :authenticate_and_audit_user, only: %i[index show]
  skip_load_and_authorize_resource only: %i[index show]
  before_action :set_types
  before_action :set_event, only: %i[show edit update destroy]

  def index
    @q ||= Event.ransack(params[:q])
    # Default, only current and future events are displayed
    @q.end_date_gteq = Date.today if params[:q].nil? || params[:q][:end_date_gteq].nil?
    @q.sorts = 'start_date asc' if @q.sorts.empty?
    @index ||= @q.result(distinct: true).page(params[:page]).per(20)
  end

  def show; end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to event_url(@event), notice: t(:event_create) }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to event_url(@event), notice: t(:event_update) }
        format.json { render :show, status: :updated, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url, notice: t(:event_destroyed) }
      format.json { head :no_content }
    end
  end

  def participants
    @breadcrumbs = [
      { label: 'events', url: events_path },
      { label: @event.name, url: event_path(@event) },
      { label: 'participants' }
    ]
    @requests = @event.travel_sponsorships.eager_load(:user).order('lower(users.nickname)').accessible_by(current_ability)
    @requests.distinct!(&:user_id)
  end

  protected

  def set_types
    @shipment_types = Rails.configuration.site['shipments']['types']
  end

  private

  def set_event
    @event = Event.find(params[:id])

    redirect_back(fallback_location: events_url) unless @event
  end

  def event_params
    attrs = %i[name description start_date end_date url country_code
               validated visa_letters request_creation_deadline
               reimbursement_creation_deadline budget_id shipment_type]
    if cannot? :validate, Event.new
      Event.validation_attributes.each do |att|
        attrs.delete(att)
      end
    end
    attrs.delete(:budget_id) if cannot? :read, Budget
    params.require(:event).permit(attrs)
  end
end
