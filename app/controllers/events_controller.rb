class EventsController < InheritedResources::Base
  respond_to :html, :js, :json
  skip_before_filter :authenticate_and_audit_user, :only => [:index, :show]
  skip_load_and_authorize_resource :only => [:index, :show]
  before_filter :set_types

  def email
    @breadcrumbs << {:label => resource, :url => resource_path}
    @breadcrumbs << {:label => 'email'}
  end

  # Send email to the event participants
  def email_event
    @email = params[:email]
    @email[:to].split(',').each do |e|
      user = User.find_by(email: e)
      EventMailer.notify_to(user, :event_info, @email)
    end
    flash[:notice] = "Email Delivered"
    redirect_to events_path
  end

  protected

  def collection
    @q ||= end_of_association_chain.search(params[:q])
    # Default, only current and future events are displayed
    if params[:q].nil? || params[:q][:end_date_gteq].nil?
      @q.end_date_gteq = Date.today
    end
    @q.sorts = "start_date asc" if @q.sorts.empty?
    @events ||= @q.result(:distinct => true).page(params[:page]).per(20)
  end

  def set_types
    @shipment_types = TravelSupport::Config.setting(:shipments, :types)
  end

  def permitted_params
    attrs = [:name, :description, :start_date, :end_date, :url, :country_code,
             :validated, :visa_letters, :request_creation_deadline,
             :reimbursement_creation_deadline, :budget_id, :shipment_type ]
    if cannot? :validate, Event.new
      Event.validation_attributes.each do |att|
        attrs.delete(att)
      end
    end
    attrs.delete(:budget_id) if cannot? :read, Budget
    params.permit(:event => attrs)
  end
end
