import React from "react"

const CompanySummary = ({ organisationEmployerName, organisationZipcode, organisationCity, organisationStreet }) => (
  <div>
    <h6>Siège de la société / administration :</h6>
    <ul>
      <li>Nom de la société employeuse : {organisationEmployerName.toUpperCase()}</li>
      <li>Adresse du siège : {organisationStreet}</li>
      <li>Ville, code postal : {organisationCity}, {organisationZipcode}</li>
    </ul>
  </div>
)

export default CompanySummary