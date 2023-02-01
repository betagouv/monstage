import React from 'react';

export default function SimpleAddressInput({
  employerName,
  employerFieldLabel,
  zipcode,
  city,
  street,
  setEmployerName,
  setZipcode,
  setCity,
  setStreet,
  resourceName
}) {
  return (
    <div>
      <div className="form-row">
        <div className="col-sm-12">
          <div className="form-group">
            <label htmlFor={`${resourceName}_employer_name`}>
              {employerFieldLabel}
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
            <input
              className="form-control"
              type="text"
              name={`${resourceName}[employer_name]`}
              id={`${resourceName}_employer_name`}
              value={employerName}
              onChange={event => (setEmployerName(event.target.value))}
            />
          </div>
        </div>
      </div>
      <div className="form-row">
        <div className="col-sm-12">
          <div className="form-group">
            <label htmlFor={`${resourceName}_street`}>
              Numéro et rue (allée, avenue, etc.)
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
            <input
              className="form-control"
              type="text"
              name={`${resourceName}[street]`}
              id={`${resourceName}_street`}
              value={street}
              onChange={event => (setStreet(event.target.value))}
            />
          </div>
        </div>
      </div>
      <div className="form-row">
        <div className="col-sm-12">
          <div className="form-group">
            <label htmlFor={`${resourceName}_city`}>
              Ville
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
            <input
              className="form-control"
              required="required"
              type="text"
              value={city}
              name={`${resourceName}[city]`}
              id={`${resourceName}_city`}
              onChange={event => (setCity(event.target.value))}
            />
          </div>
        </div>
      </div>
      <div className="form-row">
        <div className="col-sm-12">
          <div className="form-group">
            <label htmlFor={`${resourceName}_zipcode`}>
              Code postal
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
            <input
              className="form-control"
              required="required"
              type="text"
              value={zipcode}
              name={`${resourceName}[zipcode]`}
              id={`${resourceName}_zipcode`}
              onChange={event => (setZipcode(event.target.value))}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
