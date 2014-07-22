class ReimbursableRequestMailer < ApplicationMailer

  def missing_reimbursement(to, request)
    @request = request
    @url = send(:"#{request.class.model_name.singular_route_key}_url", request)
    mail(:to => to,  :subject => t(:mailer_subject_missing_reimbursement, :request => @request.title))
  end
end
