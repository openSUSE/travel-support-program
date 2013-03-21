#
# This controller only exists because inherited_resources cannot manage
# belongs_to resources associations that are both singleton and optional
#
class ReimbursementsListsController < InheritedResources::Base
  respond_to :html, :js, :json
  defaults :resource_class => Reimbursement, :collection_name => 'reimbursements'
  skip_load_and_authorize_resource
  helper_method :reimbursement_states_collection

  protected

  def collection
    @q ||= end_of_association_chain.accessible_by(current_ability).includes(:request => :expenses).search(params[:q])
    @q.sorts = "id asc" if @q.sorts.empty?
    @reimbursements ||= @q.result(:distinct => true).page(params[:page]).per(20)
  end

  def reimbursement_states_collection
    Reimbursement.state_machines[:state].states.map {|s| [ s.human_name, s.value] }
  end
end

