module ReimbursementsHelper
  def reimbursement_attachments(reimbursement)
    reimbursement.attachments.map {|a| link_to(a.title, a.file_url) }.join(", ").html_safe
  end
end
