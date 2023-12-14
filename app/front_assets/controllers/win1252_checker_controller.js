import { Controller } from 'stimulus';
// import { encode} from 'windows-1252';

export default class extends Controller {
  static targets = ['field', 'errorMessage'];

  checkWin1252(e) {
    if (this.allWin1252Chars(this.fieldTarget.value)) {
      this.errorMessageTarget.classList.add('d-none');
    } else {
      this.errorMessageTarget.classList.remove('d-none');
    }
  }

  // checks each char of a string to see if it's a win1252 char
  allWin1252Chars(str) {
    if (str == undefined || str.length === 0) { return true }

    let allCharsAllowed = true;
    for (let i = 0; i < str.length; i++) {
      if (!this.isWin1252Char(str.charCodeAt(i))) {
        allCharsAllowed = false;
        break;
      }
    }
    return allCharsAllowed;
  }

  isWin1252Char(code) {
    return (
      code === 0x9 ||
      code === 0xa ||
      code === 0xd ||
      (code >= 0x20 && code <= 0x7e) ||
      (code >= 0xa0 && code <= 0xff)
    );
  }
}
