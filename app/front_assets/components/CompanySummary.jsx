import React from "react";

const CompanySummary = ({
  organisationEmployerName,
  organisationZipcode,
  organisationCity,
  organisationStreet,
  organisationSiret,
  organisationLongitude,
  organisationLatitude,
}) => (
  <div>
    <h6>Siège de la société / administration :</h6>
    <ul>
      <li>Nom de la société employeuse : {organisationEmployerName.toUpperCase()}</li>
      <li>SIRET : {organisationSiret}</li>
      <li>Adresse du siège : {organisationStreet}</li>
      <li>Ville, code postal : {organisationCity}, {organisationZipcode}</li>
    </ul>
    <div>
      <input type='hidden' name='organisation[manual_enter]' id='organisation_manual_enter' value={false} />
      <input type='hidden' name='organisation[employer_name]' id='organisation_employer_name' value={organisationEmployerName} />
      <input type='hidden' name='organisation[street]' id='organisation_street' value={organisationStreet} />
      <input type='hidden' name='organisation[city]' id='organisation_city' value={organisationCity} />
      <input type='hidden' name='organisation[zipcode]' id='organisation_zipcode' value={organisationZipcode} />
      <input type='hidden' name='organisation[siret]' id='organisation_siret' value={organisationSiret} />
      <input type='hidden' name='organisation[coordinates_longitude]' id='organisation_coordinates_longitude' value={organisationLongitude} />
      <input type='hidden' name='organisation[coordinates_latitude]' id='organisation_coordinates_latitude' value={organisationLatitude} />
    </div>
  </div>
)

export default CompanySummary