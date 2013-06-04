module ReimbursementsHelper
  def reimbursement_attachments(reimbursement)
    if reimbursement.attachments.empty?
      I18n.t("show_for.blank")
    else
      reimbursement.attachments.map {|a| link_to(a.title, a.file_url) }.join(", ").html_safe
    end
  end

  def reimbursement_links(reimbursement)
    if reimbursement.links.empty?
      I18n.t("show_for.blank")
    else
      reimbursement.links.map {|a| link_to(a.title, a.url) }.join(", ").html_safe
    end
  end
end
