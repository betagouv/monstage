import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static targets = [
    'weeklyHoursStart',
    'weeklyHoursEnd',
    'weeklyLunchBreak',
    'dailyHoursStart',
    'dailyHoursEnd',
    'dailyLunchBreak',
  ];

  handleToggleWeeklyPlanning(){
    if($('#weekly_planning').is(":checked")){
      this.clean_daily_hours()
      this.clean_daily_lunch()
      $("#daily-planning").addClass('d-none')
      $("#daily-planning").hide()
      $("#weekly-planning").removeClass('d-none')
      $("#weekly-planning").slideDown()
    } else {
      this.clean_weekly_hours()
      this.clean_weekly_lunch()
      $("#weekly-planning").addClass('d-none')
      $("#weekly-planning").hide()
      $("#daily-planning").removeClass('d-none')
      $("#daily-planning").slideDown()
    }
  }

  clean_daily_hours() {
    this.dailyHoursStartTargets.forEach((dailyHoursStartTarget) => {
      dailyHoursStartTarget.value = '';
    })

    this.dailyHoursEndTargets.forEach((dailyHoursEndTarget) => {
      dailyHoursEndTarget.value = '';
    })
  };

  clean_daily_lunch() {
    this.dailyLunchBreakTargets.forEach((dailyLunchBreakTarget) => {
      dailyLunchBreakTarget.value = '';
    })
  };

  initialize_daily_hours() {
    var dailyHoursStart = document.getElementsByClassName('daily-hours-start');
    for (var i = 0; i < dailyHoursStart.length; i++) {
      dailyHoursStart[i].value = '09:00';
    }
    var dailyHoursEnd = document.getElementsByClassName('daily-hours-end');
    for (var i = 0; i < dailyHoursEnd.length; i++) {
      dailyHoursEnd[i].value = '17:00';
    }
  }

  clean_weekly_lunch() {
    this.weeklyLunchBreakTarget.value = '';
  }

  clean_weekly_hours() {
    this.weeklyHoursStartTarget.value = '';
    this.weeklyHoursEndTarget.value = '';
  }

  connect() {
  }
}
