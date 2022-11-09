class TravelSponsorshipsController < InheritedResources::Base
  respond_to :html, :js, :json

  skip_load_resource only: [:index, :new]
  helper_method :request_states_collection
  before_action :load_subjects

  def create
    @travel_sponsorship ||= TravelSponsorship.new(params[:request])
    @travel_sponsorship.user = current_user
    create!
  end

  def new
    @travel_sponsorship ||= TravelSponsorship.new(params[:request])
    @travel_sponsorship.event = Event.find(params[:event_id])
    @travel_sponsorship.user = current_user
    if previous = TravelSponsorship.in_conflict_with(@travel_sponsorship).first
      flash[:warning] = I18n.t(:redirect_to_previous_request)
      redirect_to previous
    else
      authorize! :create, @travel_sponsorship
      @travel_sponsorship.expenses.build
      new!
    end
  end

  def show
    @request = resource
  end

  protected

  def collection
    @q ||= end_of_association_chain.accessible_by(current_ability).includes(:expenses).ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty?
    @all_requests ||= @q.result(distinct: true)
    @travel_sponsorships ||= @all_requests.page(params[:page]).per(20)
    @requests = @travel_sponsorships
  end

  def request_states_collection
    TravelSponsorship.state_machines[:state].states.map { |s| [s.human_name, s.value] }
  end

  def load_subjects
    @subjects = Rails.configuration.site['travel_sponsorships']['expenses_subjects']
  end

  def permitted_params
    params.permit(travel_sponsorship: [:event_id, :description, :visa_letter,
                                       { expenses_attributes: [:id, :subject, :description, :estimated_amount,
                                                               :estimated_currency, :_destroy] }])
  end
end
