import React, { useEffect, useState } from 'react';
// import { throttle, debounce } from "throttle-debounce";
import Downshift from 'downshift';
import { fetch } from 'whatwg-fetch';
import CompanySummary from '../CompanySummary';
import { endpoints } from '../../utils/api';
import SimpleAddressInput from './SimpleAddressInput';

// see: https://geo.api.gouv.fr/adresse
export default function SirenInput({
  resourceName,
  currentSiret,
  currentCity,
  currentStreet,
  currentZipcode,
  currentEmployerName,
  currentLatitude,
  currentLongitude,
  edit,
  railsEnv
}) {
  // const [siret, setSiret] = useState(currentSiret || '');
  const [searchResults, setSearchResults] = useState([]);
  const [organisationZipcode, setOrganisationZipcode] = useState(currentZipcode || '');
  const [organisationStreet, setOrganisationStreet] = useState(currentStreet || '');
  const [organisationCity, setOrganisationCity] = useState(currentCity || '');
  const [organisationEmployerName, setOrganisationEmployerName] = useState(currentEmployerName || '');
  const [organisationSiret, setOrganisationSiret] = useState(currentSiret || '');
  const [organisationLatitude, setOrganisationLatitude] = useState(currentLatitude || 0);
  const [organisationLongitude, setOrganisationLongitude] = useState(currentLongitude || 0);
  const [manualEnter, setManualEnter] = useState(false)

  const inputChange = (event) => {
    setOrganisationSiret(event.target.value);
  };

  const searchCompanyBySiret = (organisationSiret) => {
    fetch(endpoints.searchCompanyBySiret({ organisationSiret }))
      .then((response) => response.json())
      .then((json) => {
        if (json.etablissements !== undefined) {
          setSearchResults(json.etablissements);
        } else {
          setSearchResults([])
        }
      });
  };

  const searchCompanyByName = (name) => {
    fetch(endpoints.searchCompanyByName({ name }))
      .then((response) => response.json())
      .then((json) => {
        if (json.etablissements !== undefined) {
          setSearchResults(json.etablissements);
        } else {
          setSearchResults([])
        }
      })
      .catch( err => {
        document.getElementById('siren-error').classList.remove('d-none');
      });
  };

  const searchCoordinatesByAddress = (fullAddress) => {
    fetch(endpoints.apiSearchAddress({ fullAddress }))
      .then((response) => response.json())
      .then((json) => {
        const [longitude, latitude] = retrieveGeoPosition(json);
        setOrganisationLongitude(longitude);
        setOrganisationLatitude(latitude);
      });
  };

  const openTooggle = (event) => {
    event.preventDefault();
    setManualEnter(!manualEnter);
  }

  const resetSearch = (event) => {
    event.preventDefault();
    setPristineSearch();
  }

  useEffect(() => {
    if (manualEnter && isAddressCompleted()) {
      const fullAddress = `${organisationStreet} ${organisationZipcode} ${organisationCity}`;
      searchCoordinatesByAddress(fullAddress);
    }
  }, [organisationEmployerName, organisationZipcode, organisationCity, organisationStreet]);

  useEffect(() => {
    const elem_error = document.getElementById('siren-error');
    if (elem_error) { elem_error.classList.add('d-none'); }
    //  a number ?
    if (/^(?=.*\d)[\d ]+$/.test(organisationSiret)) {
      const cleanSiret = organisationSiret.replace(/\s/g, '');
      if (cleanSiret.length === 14) {
        searchCompanyBySiret(cleanSiret);
      } else {
        setSearchResults([]);
      }
    // a text
    } else if (organisationSiret.length > 2) {
        searchCompanyByName(organisationSiret);
    }
  }, [organisationSiret]);

  // private methods --------------------------
  const setPristineSearch = () => {
    setOrganisationZipcode('');
    setOrganisationStreet('');
    setOrganisationCity('');
    setOrganisationEmployerName('');
    setOrganisationSiret('');
  }
  const downshiftWasUsed = () => { return (organisationZipcode != '') }

  const splitAddressDetails = (selection) => {
    setOrganisationSiret(selection.siret);
    setOrganisationEmployerName(selection.uniteLegale.denominationUniteLegale);
    const etablissement = selection.adresseEtablissement
    setOrganisationZipcode(etablissement.codePostalEtablissement);
    setOrganisationCity(etablissement.libelleCommuneEtablissement);
    const concatenetedOrganisationStreet = `${etablissement.numeroVoieEtablissement} ${etablissement.typeVoieEtablissement} ${etablissement.libelleVoieEtablissement}`;
    setOrganisationStreet(concatenetedOrganisationStreet);
    searchCoordinatesByAddress(`${concatenetedOrganisationStreet} ${etablissement.codePostalEtablissement} ${etablissement.libelleCommuneEtablissement}`);
  }

  const isAddressCompleted = () => {
    return organisationEmployerName && organisationZipcode && organisationCity && organisationStreet;
  };

  const retrieveGeoPosition = (json) => {
    const coordinates = json.features[0].geometry.coordinates;
    return [parseFloat(coordinates[0]), parseFloat(coordinates[1])];
  }

  //--------------------------------------------

  return (
    <div className="form-group" id="input-siren">
      <div className="container-downshift">
        {
          (manualEnter) ?
            (<SimpleAddressInput
              employerFieldLabel="Nom de l'entreprise ou de l'administration"
              addressTypeLabel= "Adresse du siège de l'entreprise ou de l'administration"
              resourceName={resourceName}
              currentEmployerName={organisationEmployerName}
              zipcode={organisationZipcode}
              city={organisationCity}
              street={organisationStreet}
              siret={organisationSiret}
              setEmployerName={setOrganisationEmployerName}
              setZipcode={setOrganisationZipcode}
              setCity={setOrganisationCity}
              setStreet={setOrganisationStreet}
              setSiret={setOrganisationSiret}
              searchCoordinatesByAddress={searchCoordinatesByAddress}
          />)
          :
          (downshiftWasUsed() ?
              (<CompanySummary
                resourceName={resourceName}
                addressTypeLabel="
                Adresse de l'entreprise ou de l'administration"
                employerName={organisationEmployerName}
                zipcode={organisationZipcode}
                city={organisationCity}
                street={organisationStreet}
                siret={organisationSiret}
                resetSearch={resetSearch}
              />)
            :
            (
              <Downshift
                onChange={selection => (splitAddressDetails(selection))}
                itemToString={item => (item ? item.value : '')}
              >
                {({
                  getInputProps,
                  getItemProps,
                  getLabelProps,
                  getMenuProps,
                  isOpen,
                  inputValue,
                  highlightedIndex,
                  selectedItem,
                  getRootProps,
                }) => (
                  <div>
                    <div className="form-group">
                      <label
                        {...getLabelProps({
                          className: 'label',
                          htmlFor: `${resourceName}_siren`,
                        })}
                      >
                        Rechercher votre société dans l’Annuaire des Entreprises{railsEnv === 'development' ? ' (dev only : 90943224700015)' : ''}
                      </label>
                      <div className="input-group input-siren">
                        <input
                          {...getInputProps({
                            onChange: inputChange,
                            value: organisationSiret,
                            className: 'form-control rounded-0',
                            id: `${resourceName}_siren`,
                            placeholder: 'Rechercher un nom ou un SIRET',
                            name: `${resourceName}[siren]`
                          })}
                        />
                      </div>
                      <div className='mt-2 d-flex'>
                        <small className="text-muted">Société introuvable ?</small>
                        <a href='#manual-input' className='pl-2 small' onClick={openTooggle}>Ajouter une société manuellement</a>
                      </div>
                      <div className="alerte alert-danger siren-error p-2 mt-2 d-none" id='siren-error' role="alert">
                        <small>Aucune réponse trouvée, essayez avec le SIRET.</small>
                      </div>
                    </div>
                    <div>
                      <div className="search-in-sirene bg-white shadow">
                        <ul {...getMenuProps({
                          className: 'p-0 m-0',
                        })}
                        >
                          {isOpen
                            ? searchResults.map((item, index) => (
                              <li
                                {...getItemProps({
                                  className: `py-2 px-3 listview-item ${highlightedIndex === index ? 'highlighted-listview-item' : ''
                                    }`,
                                  key: index,
                                  index,
                                  item,
                                  style: {
                                    fontWeight: highlightedIndex === index ? 'bold' : 'normal',
                                  },
                                })}
                              >
                                {item.uniteLegale.denominationUniteLegale} - {item.adresseEtablissement.libelleCommuneEtablissement}
                              </li>
                            ))
                            : null}
                        </ul>
                      </div>
                    </div>
                  </div>
                )}
              </Downshift>
            )
          )
        }
        <div>
          <input type='hidden' name={`${resourceName}[employer_name]`} id={`${resourceName}_employer_name`} value={organisationEmployerName} />
          <input type='hidden' name={`${resourceName}[street]`} id={`${resourceName}_street`} value={organisationStreet.trim()} />
          <input type='hidden' name={`${resourceName}[city]`} id={`${resourceName}_city`} value={organisationCity.trim()} />
          <input type='hidden' name={`${resourceName}[zipcode]`} id={`${resourceName}_zipcode`} value={organisationZipcode.trim()} />
          <input type='hidden' name={`${resourceName}[siret]`} id={`${resourceName}_siret`} value={organisationSiret} />
          <input type='hidden' name={`${resourceName}[coordinates][longitude]`} id={`${resourceName}_coordinates_longitude`} value={organisationLongitude} />
          <input type='hidden' name={`${resourceName}[coordinates][latitude]`} id={`${resourceName}_coordinates_latitude`} value={organisationLatitude} />
          <input type='hidden' name={`${resourceName}[manual_enter]`} id={`${resourceName}_manual_enter`} value={manualEnter} />
        </div>
      </div>
    </div>
  )
}
