import $ from 'jquery';
import { Controller } from 'stimulus';
import ActionCable from 'actioncable';
import {
  toggleElement,
  showElement,
  hideElement
} from '../utils/dom';

export default class extends Controller {
  static targets = [
    'handicapGroup',
    'emailHint',
    'emailExplanation',
    'emailInput',
    'rolelInput',
    'emailLabel',
    'emailBloc',
    'phoneBloc',
    'emailRadioButton',
    'phoneRadioButton',
    'passwordHint',
    'passwordGroup',
    'passwordInput',
    'phoneSuffix',
    'schoolPhoneBloc',
    'departmentSelect',
    'ministrySelect'
  ];
  // 'passwordConfirmationHint',
  // 'passwordConfirmationGroup',
  // 'passwordConfirmationLabel',
  // 'passwordConfirmationInput',
  // data-signup - target="emailExplanation"

  static values = {
    channel: String,
  };

  initialize() {
    // set default per specification
    this.show(this.emailBlocTarget)
    this.checkEmail();
  }

  // on change email address, ensure user is shown academia address requirement when neeeded
  refreshEmailFieldLabel(event) {
    let labelText = "Adresse électronique"
    if (["school_manager", "teacher", "main_teacher", "other"].includes(event.target.value)) {
      labelText = "Adresse électronique académique";
      this.emailLabelTarget.innerText = labelText;
      // margin adjusting
      const format = (event.target.value == "school_manager") ?
        'ce.UAI@ac-academie.fr' :
        'xxx@ac-academie.fr'
      const explanation = `Merci de saisir une adresse au format : ${format}. Cette adresse sera utilisée pour communiquer avec vous. `
      this.emailInputTarget.placeholder = format;
      $(this.emailExplanationTarget).text(explanation);
    }
    $(this.labelTarget).text();
  }

  // show/hide handicap input if checkbox is checked
  toggleHandicap() {
    toggleElement($(this.handicapGroupTarget));
  }

  // check email address formatting on email input blur (14yo student, not always good with email)
  onBlurEmailInput(event) {
    const email = event.target.value;
    if (email.length > 2) {
      this.validator.perform('validate', {
        email,
        uid: this.channelParams.uid,
        role: $('#user_role').val(),
      });
    }
  }

  cleanLocalStorageWithSchoolManager() {
    localStorage.removeItem('close_school_manager')
  }

  connect() {
    const emailHintElement = this.emailHintTarget;
    const emailInputElement = this.emailInputTarget;
    const $hint = $(emailHintElement);
    const $input = $(emailInputElement);
    if (localStorage.getItem('channel') !== undefined) {
      this.channelValue = localStorage.getItem('channel');
    }

    this.cleanLocalStorageWithSchoolManager();

    // setup wss to validate email (kind of history, tried to check email with smtp, not reliable)
    this.channelParams = {
      channel: 'MailValidationChannel',
      uid: Math.random().toString(36)
    };
    this.wssClient = ActionCable.createConsumer('/cable');
    this.validator = this.wssClient.subscriptions.create(this.channelParams, {
      received: data => {
        showElement($hint);

        switch (data.status) {
          case 'valid':
            $hint.attr('class', 'valid-feedback');
            $input.attr('class', 'fr-input is-valid');
            emailHintElement.innerText = 'Votre email semble correct!';
            break;
          case 'invalid':
            $hint.attr('class', 'fr-message fr-message--error');
            $input.attr('class', 'fr-input is-invalid');
            emailHintElement.innerText =
              'Cette adresse éléctronique ne nous semble pas valide, veuillez vérifier';
            break;
          case 'hint':
            $hint.attr('class', 'fr-message fr-message--error');
            $input.attr('class', 'fr-input is-invalid');
            emailHintElement.innerText = `Peut être avez-vous fait une erreur de frappe ? ${data.replacement}`;
            break;
          default:
            hideElement($hint);
        }
      },
    });

    setTimeout(() => {
      this.checkChannel();
    }, 100);
  }

  disconnect() {
    try {
      localStorage.clear();
      this.wssClient.disconnect();
    } catch (e) {}
  }

  onMinistryTypeChange(event) {
    const ministryType = event.target.value;
    document.getElementById('new_user').action = '/utilisateurs?as=' + ministryType;

    if ((ministryType == "EducationStatistician") || (ministryType == "PrefectureStatistician")) {
      $('#statistician-department').removeClass('d-none');
      this.departmentSelectTarget.required = true;

      $('#statistician-ministry').addClass('d-none');
      this.ministrySelectTarget.required = false;
    } else {
      $('#statistician-department').addClass('d-none');
      this.departmentSelectTarget.required = false;

      $('#statistician-ministry').removeClass('d-none');
      this.ministrySelectTarget.required = true;
    }
  }


  checkPassword() {
    const passwordHintElement = this.passwordHintTarget;
    const passwordGroupElement = this.passwordGroupTarget;
    const passwordInputTargetElement = this.passwordInputTarget;
    const $hint = $(passwordHintElement);
    const $passwordGroup = $(passwordGroupElement);
    if (passwordInputTargetElement.value.length === 0) {
      $hint.attr('class', 'text-muted');
      passwordHintElement.innerText = '(6 caractères au moins)';
    } else if (passwordInputTargetElement.value.length < 6) {
      $hint.attr('class', 'fr-message fr-message--error');
      passwordHintElement.innerText = 'Ce mot de passe est trop court, veuillez corriger.';
    } else {
      $hint.attr('class', 'd-none');
      $passwordGroup.attr('class', 'fr-password fr-input-group fr-input-group--valid');
    }
  }

  checkChannel() {
    switch (this.channelValue) {
      case 'email':
        this.checkEmail();
        break;
      case 'phone':
        this.checkPhone();
        break;
      default:
        return;
    }
  }

  checkEmail() {
    this.emailRadioButtonTarget.checked = true
    this.displayField(this.phoneInputTarget, this.phoneBlocTarget, this.emailBlocTarget, 'email')
  }

  checkPhone() {
    this.phoneRadioButtonTarget.checked = true
    this.displayField(this.emailInputTarget, this.emailBlocTarget, this.phoneBlocTarget, 'phone')
  }

  displayField(fieldToClean, fieldToHide, fieldToDisplay, channel) {
    this.clean(fieldToClean);
    this.hide(fieldToHide)
    this.show(fieldToDisplay);
    this.channelValue = channel;
    localStorage.setItem('channel', channel)
  }
  clean(fieldToClean) {
    $(fieldToClean).val('');
  }

  hide(fieldToHide) {
    $(fieldToHide).hide();
    $(fieldToHide).addClass('d-none');
  }

  show(fieldToDisplay) {
    $(fieldToDisplay).hide();
    $(fieldToDisplay).removeClass('d-none');
    $(fieldToDisplay).slideDown();
  }

  focusPhone() {
    $('#phone-input').focus()
  }
}