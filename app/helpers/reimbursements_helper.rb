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
      reimbursement.attachments.map {|a| link_to(a.title, asset_path(a.file_url)) }.join(", ").html_safe
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

  # Outputs the download link to acceptance_file, with instructions to
  # attach it if needed
  #
  # @param [Reimbursement] reimbursement
  # @return [String] HTML output
  def reimbursement_acceptance_file(reimbursement)
    if reimbursement.acceptance_file.blank?
      out = t("show_for.blank").html_safe
    else
      out = link_to(File.basename(reimbursement.acceptance_file.path), asset_path(reimbursement.acceptance_file_url))
    end
    if can? :accept, reimbursement
      out << "<br/>".html_safe
      out << content_tag(:span, "!", :class => "badge badge-info")
      out << " ".html_safe
      print_url = request_reimbursement_path(reimbursement.request, :format => :pdf)
      out << t(:reimbursement_acceptance_intro, :print_url => print_url).html_safe
    end
    out
  end
end
