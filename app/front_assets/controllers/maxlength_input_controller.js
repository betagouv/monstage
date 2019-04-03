import "../utils/bootstrap-maxlength"
import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    $(this.element).maxlength({
      alwaysShow: true,
      warningClass: "form-text text-muted mt-1", //it's the class of the element with the indicator. By default is the bootstrap "badge badge-success" but can be changed to anything you'd like.
      limitReachedClass: "form-text text-danger mt-1", //it's the class the element gets when the limit is reached. Default is "badge badge-danger". Replace with text-danger if you want it to be red.
      //separator: ' of ', //represents the separator between the number of typed chars and total number of available chars. Default is "/".
      placement: 'bottom-right-inside', //is a string, object, or function, to define where to output the counter. Possible string values are: bottom ( default option ), left, top, right, bottom-right, top-right, top-left, bottom-left and centered-right. Are also available : **bottom-right-inside** (like in Google's material design, **top-right-inside**, **top-left-inside** and **bottom-left-inside**. stom placements can be passed as an object, with keys top, right, bottom, left, and position.
    })
  }
}
