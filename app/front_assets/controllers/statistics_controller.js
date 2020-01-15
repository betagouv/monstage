import $ from 'jquery';
import { Controller } from 'stimulus';
import Turbolinks from 'turbolinks';

export default class extends Controller {
  filterByDepartment(event) {
    this.changeURLFromEvent(event, 'department');
  }

  filterByAcademy(event) {
    this.changeURLFromEvent(event, 'academy');
  }

  filterByPublicy(event) {
    this.changeURLFromEvent(event, 'is_public');
  }

  useDimension(event) {
    this.changeURLFromEvent(event, 'dimension');
  }

  changeURLFromEvent(event, param) {
    const paramValue = $(event.target).val();
    const searchParams = new URLSearchParams(window.location.search);
    if (paramValue.length === 0) {
      searchParams.delete(param);
    } else {
      searchParams.set(param, paramValue);
    }
    searchParams.delete('page');

    Turbolinks.visit(
      `${window.location.origin}${window.location.pathname}?${searchParams.toString()}`,
    );
  }
}
