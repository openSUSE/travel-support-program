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
      req = reimbursement.request
      links = reimbursement.attachments.map {|a| link_to(a.title, request_reimbursement_attachment_path(req, a))}
      links.join(", ").html_safe
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
      out = link_to(reimbursement.acceptance_file.file.filename,
                    request_reimbursement_acceptance_path(reimbursement.request))
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

  # Outputs a table containing payments, with edit and destroy links where allowed
  #
  # @param [Reimbursement] reimbursement
  # @return [String] HTML output
  def reimbursement_payments(reimbursement)
    payments = reimbursement.payments.order(:date).accessible_by(current_ability)
    if payments.empty?
      I18n.t("show_for.blank")
    else
      header = content_tag(:th, Payment.human_attribute_name(:date))
      header << content_tag(:th, Payment.human_attribute_name(:method))
      header << content_tag(:th, Payment.human_attribute_name(:subject))
      header << content_tag(:th, Payment.human_attribute_name(:amount), :class => "text-right")
      header << content_tag(:th, "")

      req = reimbursement.request
      rows = payments.map do |payment|
        p = content_tag(:td, l(payment.date, :format => :short))
        p << content_tag(:td, payment.method)
        p << content_tag(:td, payment.subject)
        p << content_tag(:td, number_to_currency(payment.amount, :unit => payment.currency), :class => "text-right")
        links = []
        if can? :update, payment
          links << link_to(t("helpers.links.edit"), edit_request_reimbursement_payment_path(req, payment))
        end
        if can? :destroy, payment
          links << link_to(t("helpers.links.destroy"),
                                 request_reimbursement_payment_path(req, payment),
                                 :confirm => t("helpers.links.confirm"), :method => :delete)
        end
        if can?(:update, payment) && !payment.file.blank?
          links << link_to(Payment.human_attribute_name(:file), file_request_reimbursement_payment_path(req, payment))
        end
        if links.empty?
          p << content_tag(:td, "")
        else
          p << content_tag(:td, "#{payment.code} (#{links.join(' | ')})".html_safe)
        end
        content_tag(:tr, p.html_safe)
      end

      content_tag(:table,
                  content_tag(:thead, content_tag(:tr, header.html_safe)) + content_tag(:tbody, rows.join("").html_safe),
                 :class => "table table-condensed")
    end
  end

end
