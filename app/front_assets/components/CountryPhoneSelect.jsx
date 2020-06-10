import React from 'react';
import PhoneInput from 'react-phone-input-2';
import 'react-phone-input-2/lib/bootstrap.css';
import $ from 'jquery';

export default function CountryPhoneSelect(){
  return (
    <PhoneInput 
      country={'fr'} 
      onlyCountries={['fr', 'gf', 'mq', 'nc', 'pf', 're']} 
      value={'fr'}
      placeholder={"ex 6 11 22 33 44"}
      localization={{gf: 'Guyane', pf: 'Polynésie Française', nc: 'Nouvelle Calédonie'}}
      inputStyle={{width: '100%', 'borderRadius': '3px'}}
      onChange={
        value => {
          console.log(value)
          $("#user_phone").val('+'+value)
        }
      }
    />
  )
}
