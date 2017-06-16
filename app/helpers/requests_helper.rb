#
# Helpers for requests' views
#
module RequestsHelper

  # Outputs the link to the reimbursement displayed in the requests list. If
  # there is no reimbursement, it outputs the button for creating it (if
  # possible).
  #
  # @param [Request] request
  # @return [String] HTML output
  def reimbursement_link(request)
    if request.reimbursement
      link_to request.reimbursement.label, request_reimbursement_path(request)
    elsif can?(:create, request.build_reimbursement)
      link_to t(:create_reimbursement_short), request_reimbursement_path(request), :method => :post, :class => 'btn btn-default btn-sm'
    else
      "-"
    end
  end
end
