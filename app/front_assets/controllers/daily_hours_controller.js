import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {

  handleToggleWeeklyPlanning(event){
    if($('#same_daily_planning').is(":checked")){
      this.clean_daily_hours()
      this.clean_daily_lunch()
      $('#weekly_start').val('9:00')
      $('#weekly_end').val('17:00')
      $("#daily-planning").addClass('d-none')
      $("#daily-planning").hide()
      $("#weekly-planning").removeClass('d-none')
      $("#weekly-planning").slideDown()
    } else {
      this.clean_weekly_hours()
      this.clean_weekly_lunch()
      this.initialize_daily_hours()
      $("#weekly-planning").addClass('d-none')
      $("#weekly-planning").hide()
      $("#daily-planning").removeClass('d-none')
      $("#daily-planning").slideDown()
    }
  }

  clean_daily_hours() {
    $("#internship_agreement_daily_hours_lundi_start").val('')
    $("#internship_agreement_daily_hours_mardi_start").val('')
    $("#internship_agreement_daily_hours_mercredi_start").val('')
    $("#internship_agreement_daily_hours_jeudi_start").val('')
    $("#internship_agreement_daily_hours_vendredi_start").val('')
    $("#internship_agreement_daily_hours_samedi_start").val('')
    
    $("#internship_agreement_daily_hours_lundi_end").val('')
    $("#internship_agreement_daily_hours_mardi_end").val('')
    $("#internship_agreement_daily_hours_mercredi_end").val('')
    $("#internship_agreement_daily_hours_jeudi_end").val('')
    $("#internship_agreement_daily_hours_vendredi_end").val('')
    $("#internship_agreement_daily_hours_samedi_end").val('')
  }
  
  clean_daily_lunch() {
    $("textarea[name*='internship_agreement[daily']").val('')
  }

  initialize_daily_hours() {
    $("#internship_agreement_daily_hours_lundi_start").val('9:00')
    $("#internship_agreement_daily_hours_mardi_start").val('9:00')
    $("#internship_agreement_daily_hours_mercredi_start").val('9:00')
    $("#internship_agreement_daily_hours_jeudi_start").val('9:00')
    $("#internship_agreement_daily_hours_vendredi_start").val('9:00')
    $("#internship_agreement_daily_hours_samedi_start").val('9:00')
    
    $("#internship_agreement_daily_hours_lundi_end").val('17:00')
    $("#internship_agreement_daily_hours_mardi_end").val('17:00')
    $("#internship_agreement_daily_hours_mercredi_end").val('17:00')
    $("#internship_agreement_daily_hours_jeudi_end").val('17:00')
    $("#internship_agreement_daily_hours_vendredi_end").val('17:00')
    $("#internship_agreement_daily_hours_samedi_end").val('17:00')
  }

  clean_weekly_lunch() {
    $("#internship_agreement_weekly_lunch_break").val('')
  }

  clean_weekly_hours() {
    $("#internship_agreement_weekly_hours_start").val('')
    $("#internship_agreement_weekly_hours_end").val('')
  }

}
