import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static values = { model: String }

  days() { return ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi']}

  handleToggleWeeklyPlanning(event) {
    if($('#same_daily_planning').is(":checked")){
      this.clean_daily_hours()
      this.clean_daily_lunch()
      $('#weekly_start').val('09:00')
      $('#weekly_end').val('17:00')
      $("#daily-planning").addClass('d-none')
                          .hide()
      $("#weekly-planning").removeClass('d-none')
                           .slideDown()
    } else {
      this.clean_weekly_hours()
      this.clean_weekly_lunch()
      this.initialize_daily_hours()
      $("#weekly-planning").addClass('d-none')
                           .hide()
      $("#daily-planning").removeClass('d-none')
                          .slideDown()
    }
  }

  clean_daily_hours() {
    this.days().forEach((day) => {
      $(`#${this.modelValue}_new_daily_hours_${day}_start`).val('');
      $(`#${this.modelValue}_new_daily_hours_${day}_end`).val('');
    });
  }

  clean_daily_lunch() {
    $(`textarea[name*='${this.modelValue}[daily]'`).val('')
  }

  initialize_daily_hours() {
    this.days().forEach((day) => {
      $(`#${this.modelValue}_new_daily_hours_${day}_start`).val('--');
      $(`#${this.modelValue}_new_daily_hours_${day}_end`).val('--');
    });
  }

  clean_weekly_lunch() {
    $(`#${this.modelValue}_weekly_lunch_break`).val('')
  }

  clean_weekly_hours() {
    $(`#${this.modelValue}_weekly_hours_start`).val('')
    $(`#${this.modelValue}_weekly_hours_end`).val('')
  }
}
