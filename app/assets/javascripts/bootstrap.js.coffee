#
#= require twitter/bootstrap
#= require datetimepicker/bootstrap-datetimepicker
#= require bootstrap-fileupload
#= require bootstrap-multiselect
#

jQuery ->
  $("a[rel~=popover], .has-popover").popover()
  $("a[rel~=tooltip], .has-tooltip").tooltip()
