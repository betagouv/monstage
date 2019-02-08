# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#internship_offer_sector').addClass 'custom-select'
  $('#internship_offer_can_be_applied_for').change ->
    $('#max_candidates_group').toggleClass 'd-none'
  return