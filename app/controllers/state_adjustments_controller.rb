class StateAdjustmentsController < ApplicationController
  respond_to :json, :js
  skip_load_and_authorize_resource
  before_filter :load_adjustment_and_authorize

  def create
    @state_adjustment.user = current_user
    flash[:notice] = t(:state_adjustment_done) if @state_adjustment.save
    respond_with(@state_adjustment, location: @back_path) do |format|
      format.js { @state_adjustment.valid? ? render : render(action: 'new') }
    end
  end

  protected

  def load_adjustment_and_authorize
    prepare_for_nested_resource
    authorize! :adjust_state, @parent
    attrs = params[:state_adjustment] ? params[:state_adjustment].permit(:notes, :to) : {}
    @state_adjustment = @parent.state_adjustments.build(attrs)
    @state_names = @parent.class.state_machines[:state].states.map(&:name)
  end
end
