import { Controller } from "stimulus"
import Turbolinks from 'turbolinks';

// should be a link, but have to check with Brice why ...
export default class extends Controller {
  visit() {
    Turbolinks.visit(this.data.get('href'))
  }
}
