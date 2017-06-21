class EventEmailsController < InheritedResources::Base
  actions :all, except: [:edit, :update, :destroy]
  belongs_to :event

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
    params.permit(event_email: [:to, :subject, :body])
  end
end
