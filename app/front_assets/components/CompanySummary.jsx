import React from "react";

const CompanySummary = ({
  organisationEmployerName,
  organisationZipcode,
  organisationCity,
  organisationStreet,
  organisationSiret,
  organisationStreetComplement,
  resetSearch,
}) => (
  <div>
    <div className="fr-text--lg fr-mb-2w">Siège de la société / administration :</div>
    <div className="fr-highlight">
      <p className="fr-text--lg">
        {organisationEmployerName.toUpperCase()}
        <br/>
        {organisationStreet}
        <br />
        {
          organisationStreetComplement && ( organisationStreetComplement + <br /> )
        }
        {organisationCity}, {organisationZipcode}
        <br/>
        SIRET : {organisationSiret}
        {/* <br/>
        Longitude, latitude : {organisationLongitude}, {organisationLatitude} */}
      </p>
    </div>
    <div className = 'text-right fr-mr-8w'>
      <a href='#' onClick={resetSearch}>... ou refaire une recherche</a>
    </div>
    
  </div>
)

export default CompanySummary