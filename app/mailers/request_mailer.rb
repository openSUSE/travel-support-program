class RequestMailer < ApplicationMailer

  def missing_reimbursement(to, request)
    @request = request
    mail(:to => to,  :subject => t(:mailer_subject_missing_reimbursement, :request => @request.title))
  end
end
