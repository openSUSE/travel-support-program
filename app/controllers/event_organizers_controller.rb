# frozen_string_literal: true

class EventOrganizersController < ApplicationController
  prepend_before_action :set_event
  before_action :set_event_organizer, only: %i[destroy]

  def index
    @event_organizers = EventOrganizer.where(event: @event)
  end

  def new
    @event_organizer = EventOrganizer.new
  end

  def create
    @event_organizer = EventOrganizer.new(event_organizer_params)
    @event_organizer.user = User.find_by(email: params[:event_organizer][:user_email])
    @event_organizer.event = @event

    respond_to do |format|
      if @event_organizer.save
        format.html { redirect_to event_event_organizers_url, notice: t(:event_organizer_create) }
        format.json { render :show, status: :created, location: @event_organizer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event_organizer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event_organizer.destroy

    respond_to do |format|
      format.html { redirect_to event_event_organizers_url, notice: t(:event_organizer_destroyed) }
      format.json { head :no_content }
    end
  end

  def autocomplete_user
    render json: EventOrganizer.autocomplete_users(params[:term])
  end

  def set_breadcrumbs
    @breadcrumbs = [
      { label: 'events', url: events_path },
      { label: @event.name, url: event_path(@event) },
      { label: EventOrganizer.model_name.human(count: 2), url: event_event_organizers_path(@event) }
    ]
    @breadcrumbs << { label: 'Add' } if action_name == 'new'
  end

  private

  def set_event
    @event = Event.find(params[:event_id])

    redirect_back(fallback_location: events_url) unless @event
  end

  def set_event_organizer
    @event_organizer = EventOrganizer.find(params[:id])

    redirect_back(fallback_location: event_event_organizers_url) unless @event_organizer
  end

  def event_organizer_params
    params.require(:event_organizer).permit(:user_email)
  end
end
