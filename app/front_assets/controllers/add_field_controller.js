import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['insertionPoint', 'count']
  static values = {
    field: String,
    scope: String,
    count: Number
  }

  makeField() {
    console.log('makeField');
    console.log('this.countValue : ' + this.countValue);
    let newField = document.createElement('input');
    const field = this.fieldValue;
    const scope = this.scopeValue;
    newField.setAttribute('type', 'email');
    newField.setAttribute('name', `${scope}[${field}]`);
    newField.setAttribute('id', `${scope}_${field}`);
    newField.setAttribute('class', 'fr-input');
    newField.setAttribute('data-target', 'add-field.insertionPoint');
    newField.setAttribute('required', 'required');
    
    console.log('newField : ' + newField);
    
    return newField;
  }

  add() {
    console.log('add');
    const newField = this.makeField();
    this.insertionPointTarget.appendChild(newField);
  }

  connect() {
    console.log('this.fieldValue : ' + this.fieldValue);
    
  }
}
