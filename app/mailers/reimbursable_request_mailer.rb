# frozen_string_literal: true

class ReimbursableRequestMailer < ApplicationMailer
  def missing_reimbursement(receiver, request)
    @request = request
    @url = send(:"#{request.class.model_name.singular_route_key}_url", request)
    mail(to: receiver, subject: t(:mailer_subject_missing_reimbursement, request: @request.title))
  end
end
