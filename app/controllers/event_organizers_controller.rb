class EventOrganizersController < InheritedResources::Base
  belongs_to :event
  actions :all, except: %i[show edit update]

  def create
    @event_organizer.user = User.find_by(email: params[:event_organizer][:user_email])
    create!(notice: 'Event Organizer Added')
  end

  def autocomplete_user
    render json: EventOrganizer.autocomplete_users(params[:term])
  end

  def permitted_params
    params.permit(event_organizer: [:user_email])
  end

  def set_breadcrumbs
    @breadcrumbs = [
      { label: 'events', url: events_path },
      { label: @event.name, url: event_path(@event) },
      { label: resource_class.model_name.human(count: 2), url: collection_path }
    ]
    @breadcrumbs << { label: 'Add' } if action_name == 'new'
  end
end
