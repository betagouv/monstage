import React from "react";

const CompanySummary = ({
  employerName,
  zipcode,
  city,
  street,
  siret,
  resetSearch,
  addressTypeLabel,
}) => (
  <div>
    <div className="fr-text--lg fr-mb-2w">{addressTypeLabel} :</div>
    <div className="fr-highlight">
      <p className="fr-text--lg">
        {employerName.toUpperCase()}
        <br/>
        {street}
        <br />
        {city}, {zipcode}
        {(siret) ? ( <br /> ) : ''}
        {(siret) ? ( `SIRET : ${siret}` ) : ''}
      </p>
    </div>
    <div className = 'text-right fr-mr-8w'>
      <a href='#' onClick={resetSearch}>... ou refaire une recherche</a>
    </div>
  </div>
)

export default CompanySummary