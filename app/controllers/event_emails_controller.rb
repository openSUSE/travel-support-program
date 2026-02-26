# frozen_string_literal: true

class EventEmailsController < ApplicationController
  authorize_resource :event
  authorize_resource :event_email, through: :event
  prepend_before_action :set_event
  before_action :set_event_email, only: %i[show]
  after_action :notify_receivers, only: %i[create]

  def preview
    @content = params[:content]
  end

  def index
    @event_emails = EventEmail.where(event: @event)
  end

  def show; end

  def new
    @event_email = EventEmail.new
  end

  def create
    @event_email = EventEmail.new(event_email_params)
    @event_email.event = @event
    @event_email.user = current_user

    respond_to do |format|
      if @event_email.save
        format.html { redirect_to event_event_emails_url(@event), notice: t(:event_email_create) }
        format.json { render :show, status: :created, location: @event_email }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event_email.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def set_breadcrumbs
    @breadcrumbs = [
      { label: 'events', url: events_path },
      { label: @event.name, url: event_path(@event) },
      { label: EventEmail.model_name.human(count: 2), url: event_event_emails_path(@event) }
    ]
    @breadcrumbs << { label: 'new' } if action_name == 'new'
    @breadcrumbs << { label: @event_email, url: event_event_email_path(@event, @event_email) } if action_name == :show
  end

  private

  def event_email_params
    params.require(:event_email).permit(%i[to subject body])
  end

  def set_event
    @event = Event.find(params[:event_id])

    redirect_back(fallback_location: events_url) unless @event
  end

  def set_event_email
    @event_email = EventEmail.find(params[:id])

    redirect_back(fallback_location: event_event_emails_url) unless @event_email
  end

  def notify_receivers
    return unless @event_email.errors.empty?

    @event_email[:to].split(',').each do |e|
      user = User.find_by(email: e)
      EventMailer.notify_to(user, :event_info, @event_email)
    end
  end
end
