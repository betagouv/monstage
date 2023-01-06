import React, { useEffect, useState } from 'react';

// see: https://geo.api.gouv.fr/adresse
export default function SimpleAddressInput({
  organisationEmployerName,
  organisationZipcode,
  organisationCity,
  organisationStreet,
  setOrganisationEmployerName,
  setOrganisationZipcode,
  setOrganisationCity,
  setOrganisationStreet,
  setOrganisationStreetComplement,
  resourceName
}) {

  return (
    <div>
      <div className="h6">Adresse du siège de l'entreprise ou de l'administration</div>
      <div className="form-row">
        <div className="col-sm-12">
          <div className="form-group">
            <label htmlFor={`${resourceName}_employer_name`}>
              Nom de l'entreprise / administration
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
            <input
              className="form-control"
              type="text"
              name={`${resourceName}[employer_name]`}
              id={`${resourceName}_employer_name`}
              value={organisationEmployerName}
              onChange={event => (setOrganisationEmployerName(event.target.value))}
            />
          </div>
        </div>
      </div>
      <div className="form-row">
        <div className="col-sm-12">
          <div className="form-group">
            <label htmlFor={`${resourceName}_street`}>
              Rue
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
            <input
              className="form-control"
              type="text"
              name={`${resourceName}[street]`}
              id={`${resourceName}_street`}
              value={organisationStreet}
              onChange={event => (setOrganisationStreet(event.target.value))}
            />
          </div>
        </div>
      </div>
      <div className="form-row">
        <div className="col-sm-12">
          <div className="form-group">
            <label htmlFor={`${resourceName}_street_complement`}>
              Complément d'adresse
            </label>
            <input
              className="form-control"
              type="text"
              value={organisationStreetComplement}
              name={`${resourceName}[street_complement]`}
              id={`${resourceName}_street_complement`}
              onChange={event => (setOrganisationStreetComplement(event.target.value))}
            />
          </div>
        </div>
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
              value={organisationCity}
              name={`${resourceName}[city]`}
              id={`${resourceName}_city`}
              onChange={event => (setOrganisationCity(event.target.value))}
            />
          </div>
        </div>
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
              value={organisationZipcode}
              name={`${resourceName}[zipcode]`}
              id={`${resourceName}_zipcode`}
              onChange={event => (setOrganisationZipcode(event.target.value))}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
