class StateTransitionsController < ApplicationController
  respond_to :json, :js
  skip_load_and_authorize_resource
  before_filter :load_transition_and_authorize

  # Not using respond_with because it relies on #valid?, but validations
  # are not the main reason for #save to return false. Callbacks are.
  def create
    @state_transition.user = current_user
    respond_to do |format|
      if @state_transition.save
        flash[:notice] = t("activerecord.state_machines.messages.#{@state_transition.state_event}_success")
        format.js { render }
        format.json { render :json => @state_transition, :status => :created, :location => @back_path }
      else
        flash[:error] = t("activerecord.state_machines.messages.#{@state_transition.state_event}_failure")
        flash[:error] << "\n<br/>" + @state_transition.machine.errors.full_messages.map {|i| i.humanize + "."}.join(" ")
        # flash messages are kept by default after javascript requests
        flash.discard
        format.js { render :action => "new" }
        format.json { render :json => @state_transition.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

  def load_transition_and_authorize
    prepare_for_nested_resource
    @state_transition = @parent.transitions.build(params[:state_transition])
    authorize! @state_transition.state_event.to_sym, @parent
  end
end
