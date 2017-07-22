# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require bootstrap
#= require cocoon
#= require additional
#= require event_emails
#= require autocomplete-rails
#

window.init_page = ->
  $('input.dpicker.date-with-time').datetimepicker()
  $('input.dpicker.date-without-time').datetimepicker
    minView: 2

  $('#event_end_date.dpicker').datetimepicker "setStartDate", $('#event_start_date.dpicker').val()

  $('#event_start_date.dpicker').datetimepicker().on "changeDate", (date) ->
    $('#event_end_date.dpicker').datetimepicker "setStartDate", $('#event_start_date.dpicker').val()

  $('#attachments').bind "cocoon:after-insert", (e, added) ->
    added.fileupload()

  $('.tab-trigger').click ->
    $(this).tab('show')

  $('select[multiple]').each ->
    $(this).multiselect
      enableCaseInsensitiveFiltering: $(this).data('enable-filtering')
      numberDisplayed: $(this).data('number-displayed')
      nonSelectedText: $(this).data('non-selected-text')
      nSelectedText: $(this).data('n-selected-text')

window.build_dialog = (selector, content) ->
  # Close it and remove content if it's already open
  $("#" + selector).modal 'hide'
  $("#" + selector).remove()
  # Add new content and pops it up
  $("body").append "<div id=\"" + selector + "\" class=\"modal fade\" role=\"dialog\">\n" + content + "</div>"
  $("#" + selector).modal()

$(document).ready ->
  init_page()
