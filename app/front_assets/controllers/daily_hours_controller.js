import { Controller } from 'stimulus';
import $ from 'jquery';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {

  handleToggleWeeklyPlanning(event){
    if($('#same_daily_planning').is(":checked")){
      $('#weekly_start').val('9:00')
      $('#weekly_end').val('17:00')
      $("#daily-planning").addClass('d-none')
      $("#daily-planning").hide()
      $("#weekly-planning").removeClass('d-none')
      $("#weekly-planning").slideDown()
    } else {
      $('#weekly_start').val('--')
      $('#weekly_end').val('--')
      $("#weekly-planning").addClass('d-none')
      $("#weekly-planning").hide()
      $("#daily-planning").removeClass('d-none')
      $("#daily-planning").slideDown()
    }
  }

}
