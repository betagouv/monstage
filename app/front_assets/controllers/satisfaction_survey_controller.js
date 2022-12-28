import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static values = {
    tally: String
  };

  connect() {
    const tallyId = this.tallyValue;

    const answer = () => {
      console.log('answer');
      $.ajax({
        url: "/answer_survey",
        type: "PATCH",
        data: ""
      }).done(
        Tally.closePopup(tallyId)
      );
    };

    Tally.openPopup(
      tallyId,
      {
        hideTitle: true,
        autoClose: 1000,
        onSubmit: (payload) => {
          answer();
        }
      }
    )
  }
}
