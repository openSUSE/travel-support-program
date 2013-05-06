class FinalNotesController < ApplicationController
  respond_to :json, :js
  skip_load_and_authorize_resource
  before_filter :load_note_and_authorize

  def create
    @final_note.user = current_user
    @final_note.save
    respond_with(@final_note) do |format|
      format.js {
        if @final_note.valid?
          flash[:notice] = t("final_note_added")
          render :create
        else
          flash[:error] = t("final_note_failed")
          flash.discard # Using JS responses, must be discarded manually
          render :new
        end
      }
    end
  end

  protected

  def load_note_and_authorize
    prepare_for_nested_resource
    @final_note = @parent.final_notes.build(params[:final_note])
    authorize! :create, @final_note
  end
end
