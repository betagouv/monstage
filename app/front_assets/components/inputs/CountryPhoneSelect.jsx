import React from 'react';
import PropTypes from 'prop-types';
import PhoneInput from 'react-phone-input-2';
import 'react-phone-input-2/lib/bootstrap.css';

class CountryPhoneSelect extends React.Component {
  static propTypes = {
    name: PropTypes.string,
    value: PropTypes.string,
    disabled: PropTypes.bool,
  };

  render() {
    return (
      <PhoneInput
        country="fr"
        onlyCountries={['fr', 'gf', 'mq', 'nc', 'pf', 're']}
        countryCodeEditable={false}
        value={this.props.value || ''}
        disabled={this.props.disabled || false}
        placeholder="ex 06 11 22 33 44"
        localization={{
          fr: 'France Métropolitaine',
          gf: 'Guyane',
          pf: 'Polynésie Française',
          nc: 'Nouvelle Calédonie',
        }}
        masks={{ fr: '.. .. .. .. ..' }}
        inputStyle={{ width: '100%', borderRadius: '3px' }}
        inputProps={{
          name: this.props.name,
          id: 'phone-input',
          'data-target': 'signup.phoneInput',
        }}
      />
    );
  }
}

export default CountryPhoneSelect;
