#
#= require twitter/bootstrap
#= require datetimepicker/bootstrap-datetimepicker
#

jQuery ->
  $("a[rel=popover]").popover()
  $(".with-tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
