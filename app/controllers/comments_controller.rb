class CommentsController < ApplicationController
  respond_to :json, :js
  skip_load_and_authorize_resource
  before_filter :load_command_and_authorize

  def create
    @comment.user = current_user
    @comment.save
    respond_with(@comment) do |format|
      format.js {
        if @comment.valid?
          flash[:notice] = t("comment_added")
          render :create
        else
          flash[:error] = t("comment_failed")
          flash.discard # Using JS responses, must be discarded manually
          render :new
        end
      }
    end
  end

  protected

  def load_command_and_authorize
    prepare_for_nested_resource
    @comment = @parent.comments.build(params[:comment])
    if action_name.to_sym == :new && Comment.private_role?(current_user.profile.role_name)
      @comment.private = true
    end
    authorize! :create, @comment
  end
end
