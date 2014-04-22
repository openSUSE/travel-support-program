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

    links = []
    if can_read_pdf_for? resource
      links << link_to(t(:pdf_format), request_reimbursement_path(reimbursement.request, :format => :pdf))
    end
    if can? :accept, reimbursement
      links << link_to(t(:send_reimbursement_acceptance), new_request_reimbursement_acceptance_path(resource.request), :remote => true)
    end

    if can? :accept, reimbursement
      info = t(:reimbursement_acceptance_intro).html_safe
    elsif current_user == reimbursement.user && !reimbursement.acceptance_file.blank?
      info = t(:reimbursement_acceptance_warning).html_safe
    else
      info = t(:reimbursement_acceptance_blank).html_safe
    end
    info << content_tag(:p, links.join(" | ").html_safe, :class => "text-right")
    unless info.empty?
      out << content_tag(:div, info, :class => "alert-info")
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
      content_tag(:p, I18n.t("show_for.blank"))
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
                 :class => "table table-condensed", :id => "reimbursement-payments")
    end
  end

  # Outputs a link to the reimbursement's check request only if everything
  # related to check requests is configured
  #
  # @param [Reimbursement] reimbursement
  # @return [String] HTML output
  def check_request_link(reimbursement)
    return "" if TravelSupport::Config.setting(:check_request_layout).blank?
    return "" if TravelSupport::Config.setting(:check_request_template).blank?
    url = check_request_request_reimbursement_path(reimbursement.request)
    link_to t(:check_request), url, :class => "btn"
  end

  # Outputs the value for the given reimbursement of one of the check request's
  # fields
  #
  # @param [Reimbursement] reimb   the reimbursement
  # @param [#to_sym]  field  the name of one of the fields defined in check requests
  # @return [String] value to show in the resulting pdf
  def check_request_value(reimb, field)
    case field.to_sym
    when :amount
      expenses_sum(reimb, :authorized)
    when :full_name
      reimb.user.profile.full_name
    when :date
      l(Date.today)
    when :postal_address
      reimb.user.profile.postal_address
    when :city
      reimb.user.profile.location
    when :country
      country_label(reimb.user.profile.country_code)
    when :zip_code
      reimb.user.profile.zip_code
    when :phone_number
      reimb.user.profile.phone_number
    end
  end

  # Checks whether the current user should be authorized to read the pdf version of a reimbursement, since the
  # pdf version includes information about the user profile and bank information.
  #
  # @param [Reimbursement] reimb  the reimbursement
  # @return [Boolean] true if authorized
  def can_read_pdf_for?(reimb)
    can?(:read, reimb) && can?(:read, reimb.user.profile) && (reimb.bank_account.nil? || can?(:read, reimb.bank_account))
  end
end
