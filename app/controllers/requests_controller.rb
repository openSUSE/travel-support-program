class RequestsController < InheritedResources::Base
  respond_to :html, :js, :json
  skip_load_resource :only => [:index, :new]
  helper_method :request_states_collection
  before_filter :load_subjects

  def create
    @request ||= Request.new(params[:request])
    @request.user = current_user
    create!
  end

  def new
    @request ||= Request.new(params[:request])
    @request.event = Event.find(params[:event_id])
    @request.user = current_user
    if previous = Request.in_conflict_with(@request).first
      flash[:warning] = I18n.t(:redirect_to_previous_request)
      redirect_to previous
    else
      authorize! :create, @request
      @request.expenses.build
      new!
    end
  end

  def show
    # We don't want to break the normal process if something goes wrong
    resource.user.profile.refresh rescue nil
    show!
  end

  protected

  def collection
    @q ||= end_of_association_chain.accessible_by(current_ability).includes(:expenses).search(params[:q])
    @q.sorts = "id asc" if @q.sorts.empty?
    @all_requests ||= @q.result(:distinct => true)
    @requests ||= @all_requests.page(params[:page]).per(20)
  end

  def request_states_collection
    Request.state_machines[:state].states.map {|s| [ s.human_name, s.value] }
  end

  def load_subjects 
    @subjects = TravelSupportProgram::Config.setting :request_expense_subjects
  end

end
