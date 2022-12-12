# frozen_string_literal: true

class ReimbursementAttachmentsController < ApplicationController
  skip_load_and_authorize_resource

  def show
    @request = Request.find(params[:request_id])
    @reimbursement = @request.reimbursement
    authorize! :read, @reimbursement
    @attachment = @reimbursement.attachments.find(params[:id])
    send_file @attachment.file.path
  end
end
