class EventsController < InheritedResources::Base
  respond_to :html, :js, :json
  skip_before_filter :authenticate_and_audit_user, only: [:index, :show]
  skip_load_and_authorize_resource only: [:index, :show]
  before_filter :set_types

  def participants
    @breadcrumbs = [
      { label: 'events', url: events_path },
      { label: @event.name, url: event_path(@event) },
      { label: 'participants' }
    ]
    @requests = @event.travel_sponsorships.eager_load(:user).order('lower(users.nickname)').accessible_by(current_ability)
    @requests.uniq!(&:user_id)
  end

  protected

  def collection
    @q ||= end_of_association_chain.search(params[:q])
    # Default, only current and future events are displayed
    if params[:q].nil? || params[:q][:end_date_gteq].nil?
      @q.end_date_gteq = Date.today
    end
    @q.sorts = 'start_date asc' if @q.sorts.empty?
    @events ||= @q.result(distinct: true).page(params[:page]).per(20)
  end

  def set_types
    @shipment_types = TravelSupport::Config.setting(:shipments, :types)
  end

  def permitted_params
    attrs = [:name, :description, :start_date, :end_date, :url, :country_code,
             :validated, :visa_letters, :request_creation_deadline,
             :reimbursement_creation_deadline, :budget_id, :shipment_type]
    if cannot? :validate, Event.new
      Event.validation_attributes.each do |att|
        attrs.delete(att)
      end
    end
    attrs.delete(:budget_id) if cannot? :read, Budget
    params.permit(event: attrs)
  end
end
