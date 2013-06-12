#
# Helpers for reimbursements' views
#
module ReimbursementsHelper

  # Outputs a comma-separated list of attachments for a given reimbursement,
  # including the download link
  #
  # @param [Reimbursement] reimbursement
  # @return [String] HTML output
  def reimbursement_attachments(reimbursement)
    if reimbursement.attachments.empty?
      I18n.t("show_for.blank")
    else
      reimbursement.attachments.map {|a| link_to(a.title, a.file_url) }.join(", ").html_safe
    end
  end

  # Outputs a comma-separated list of links for a given reimbursement,
  #
  # @param [Reimbursement] reimbursement
  # @return [String] HTML output
  def reimbursement_links(reimbursement)
    if reimbursement.links.empty?
      I18n.t("show_for.blank")
    else
      reimbursement.links.map {|a| link_to(a.title, a.url) }.join(", ").html_safe
    end
  end
end
