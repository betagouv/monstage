import React, { useEffect, useState } from 'react';

// see: https://geo.api.gouv.fr/adresse
export default function SimpleAddressInput({
  resourceName,
}) {
  return (
    <div>
      <div className="h6">Adresse du siège de l'entreprise ou de l'administration</div>
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
              name={`${resourceName}[street_complement]`}
              id={`${resourceName}_street_complement`}
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
              name={`${resourceName}[city]`}
              id={`${resourceName}_city`}
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
              name={`${resourceName}[zipcode]`}
              id={`${resourceName}_zipcode`}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
