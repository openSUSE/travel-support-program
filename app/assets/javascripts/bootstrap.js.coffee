#
#= require twitter/bootstrap
#= require datetimepicker/bootstrap-datetimepicker
#= require bootstrap-fileupload
#= require bootstrap-multiselect
#

jQuery ->
  $("a[rel=popover]").popover()
  $(".with-tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
