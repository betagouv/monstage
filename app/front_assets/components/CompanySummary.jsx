import React from "react";

const CompanySummary = ({
  employerName,
  zipcode,
  city,
  street,
  siret,
  addressTypeLabel,
}) => (
  <div>
    {addressTypeLabel != ""  && (<div className="fr-text--lg fr-mb-2w">{addressTypeLabel} :</div>)}
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
  </div>
)

export default CompanySummary