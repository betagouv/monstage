import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static targets = [
    'weeklyHoursStart',
    'weeklyHoursEnd',
    'dailyHoursStart',
    'dailyHoursEnd',
  ];

  handleToggleWeeklyPlanning() {
    if ($('#weekly_planning').is(":checked")) {
      this.clean_daily_hours()
      $("#daily-planning-container").addClass('d-none')
      $("#daily-planning-container").hide()
      $("#weekly-planning").removeClass('d-none')
      $("#weekly-planning").slideDown()
    } else {
      this.clean_weekly_hours()
      $("#weekly-planning").addClass('d-none')
      $("#weekly-planning").hide()
      $("#daily-planning-container").removeClass('d-none')
      $("#daily-planning-container").slideDown()
    }
  }

  weeklyStartChange() {
    const start = this.getIFromTime(this.weeklyHoursStartTarget.value);

    if (start) {
      Array.from(this.weeklyHoursEndTarget.options).forEach(opt => {
        if (this.getIFromTime(opt.value) < start + 4) {
          opt.disabled = true;
        }
      });
      this.weeklyHoursEndTarget.disabled = false;
    } else {
      this.weeklyHoursEndTarget.disabled = false;
      this.enableAllOptions(this.weeklyHoursEndTarget);
    }
  }

  weeklyEndChange() {
    const end = this.getIFromTime(this.weeklyHoursEndTarget.value);

    if (end) {
      Array.from(this.weeklyHoursStartTarget.options).forEach(opt => {
        if (this.getIFromTime(opt.value) > end - 4) {
          opt.disabled = true;
        }
      });
      this.weeklyHoursStartTarget.disabled = false;
    } else {
        this.weeklyHoursStartTarget.disabled = false;
        this.enableAllOptions(this.weeklyHoursStartTarget);
    }
  }


  dailyHoursStartChange(event) {
    const i = event.target.dataset.i
    const start = this.getIFromTime(this.dailyHoursStartTargets[i].value);

    if (start) {
      let dailyHoursEnd = document.getElementsByClassName('daily-hours-end')[i];
      this.disableOptionBeforeStart(dailyHoursEnd, start);
      dailyHoursEnd.disabled = false;
    } else {
      this.dailyHoursEndTargets[i].disabled = false;
      this.enableAllOptions(this.dailyHoursEndTargets[i]);
    }
  }

  dailyHoursEndChange(event) {
    const i = event.target.dataset.i;
    const end = this.getIFromTime(this.dailyHoursEndTargets[i].value);

    // if end not Nan
    if (end) {
      const dailyHoursStart = document.getElementsByClassName('daily-hours-start')[i];
      this.disableOptionAfterEnd(dailyHoursStart, end);
      dailyHoursStart.disabled = false;
    } else {
      this.dailyHoursStartTargets[i].disabled = false;
      this.enableAllOptions(this.dailyHoursStartTargets[i]);
    }
  }

  disableOptionBeforeStart(element, start) {
    Array.from(element.options).forEach(opt => {
      if (this.getIFromTime(opt.value) < start + 4) {
        opt.disabled = true;
      }
    });
  }

  disableOptionAfterEnd(element, end) {
    Array.from(element.options).forEach(opt => {
      if (this.getIFromTime(opt.value) > end - 4) {
        opt.disabled = true;
      }
    });
  }

  enableAllOptions(element) {
    Array.from(element.options).forEach(opt => {
      opt.disabled = false;
    });
  }

  formatTime(i) {
    var hour = Math.floor(i / 4);
    var min = 15 * (i - (hour * 4));
    return `${this.formatNumber(hour)}:${this.formatNumber(min)}`;
  }

  formatNumber(number) {
    if (number < 10) {
      return `0${number}`;
    } else {
      return `${number}`;
    }
  }

  getIFromTime(time) {
    var hour = parseInt(time.split(':')[0]);
    var min = parseInt(time.split(':')[1]);
    return hour * 4 + min / 15;
  }

  clean_daily_hours() {
    this.dailyHoursStartTargets.forEach((dailyHoursStartTarget) => {
      dailyHoursStartTarget.value = '';
    })

    this.dailyHoursEndTargets.forEach((dailyHoursEndTarget) => {
      dailyHoursEndTarget.value = '';
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

  clean_weekly_hours() {
    this.weeklyHoursStartTarget.value = '';
    this.weeklyHoursEndTarget.value = '';
  }

  connect() {
  }
}
