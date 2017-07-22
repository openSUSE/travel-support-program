class EventOrganizersController < InheritedResources::Base
  autocomplete :user, :email
  belongs_to :event
  actions :all, except: [:show, :edit, :update]

  def create
    @event_organizer.user = User.find_by(email: params[:event_organizer][:user_email])
    create!(notice: 'Event Organizer Added')
  end

  def permitted_params
    params.permit(event_organizer: [:user_email])
  end
end
