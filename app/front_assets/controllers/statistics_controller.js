import { Controller } from 'stimulus';
import { changeURLFromEvent} from '../utils/urls';

export default class extends Controller {

  filterByDepartment(event) {
    changeURLFromEvent(event, 'department');
  }

  filterByAcademy(event) {
    changeURLFromEvent(event, 'academy');
  }

  filterByPublicy(event) {
    changeURLFromEvent(event, 'is_public');
  }

  filterBySchoolYear(event) {
    changeURLFromEvent(event, 'school_year');
  }

  filterBySubscribedSchool(event) {
    changeURLFromEvent(event, 'subscribed_school');
  }

  useDimension(event) {
    changeURLFromEvent(event, 'dimension');
  }
}

