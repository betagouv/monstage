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

  useDimension(event) {
    changeURLFromEvent(event, 'dimension');
  }
}
