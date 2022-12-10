class EventEmailsController < InheritedResources::Base
  actions :all, except: %i[edit update destroy]
  belongs_to :event
  load_and_authorize_resource :event
  load_and_authorize_resource :event_email, through: :event

  def preview
    @content = params[:content]
  end

  def create
    @event_email.user = current_user
    create!(notice: 'Email Delivered')
    return unless @event_email.errors.empty?
    @event_email[:to].split(',').each do |e|
      user = User.find_by(email: e)
      EventMailer.notify_to(user, :event_info, @event_email)
    end
  end

  protected

  def permitted_params
    params.permit(event_email: %i[to subject body])
  end

  def set_breadcrumbs
    @breadcrumbs = [
      { label: 'events', url: events_path },
      { label: @event.name, url: event_path(@event) },
      { label: resource_class.model_name.human(count: 2), url: collection_path }
    ]
    @breadcrumbs << { label: 'new' } if action_name == 'new'
    @breadcrumbs << { label: resource, url: resource_path } if %w[show edit update].include? action_name
  end
end
