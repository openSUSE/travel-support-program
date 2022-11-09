class CommentsController < ApplicationController
  respond_to :json, :js
  skip_load_and_authorize_resource
  before_action :load_command_and_authorize

  def create
    @comment.user = current_user
    @comment.save
    respond_with(@comment) do |format|
      format.js do
        if @comment.valid?
          flash[:notice] = t('comment_added')
          render :create
        else
          flash[:error] = t('comment_failed')
          flash.discard # Using JS responses, must be discarded manually
          render :new
        end
      end
    end
  end

  protected

  def load_command_and_authorize
    prepare_for_nested_resource
    @comment = if action_name.to_sym == :new
                 @parent.comments.build(private: @parent.class.allow_private_comments?(current_user.profile.role_name))
               else
                 @parent.comments.build(body: params[:comment][:body],
                                        private: params[:comment][:private])
               end
    authorize! :create, @comment
  end
end
