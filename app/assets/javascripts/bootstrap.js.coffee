#
#= require twitter/bootstrap
#= require datetimepicker/bootstrap-datetimepicker
#= require bootstrap-fileupload
#

jQuery ->
  $("a[rel=popover]").popover()
  $(".with-tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
