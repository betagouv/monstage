import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'mandatoryField',
    'disabledField'
  ];

  static values = {
    minimumLength: Number
  }

  fieldChange(event){
    console.log('fieldChange');
    this.checkValidation();
  }

  areAllMandatoryFieldsFilled(){
    let allMandatoryFieldsAreFilled = true;
    this.mandatoryFieldTargets.forEach((field) => {
      if (field.value.length <= this.minimumLengthValue) {
        allMandatoryFieldsAreFilled = false;
      }
    });
    return allMandatoryFieldsAreFilled;
  }

  // possible values are 'disabled' or 'enabled'
  setDisabledFieldsTo(status){

    const disabledFields = this.disabledFieldTargets;
    disabledFields.forEach((field) => {
      field.disabled =  (status === 'disabled') ;
    });
  }

  checkValidation(){
    if(this.areAllMandatoryFieldsFilled()){
      this.setDisabledFieldsTo('enabled');
    } else {
      this.setDisabledFieldsTo('disabled');
    }
  }

  connect(){
    this.checkValidation();
  }
}