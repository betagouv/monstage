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
  railsEnv
}) {
  const [siret, setSiret] = useState(currentSiret || '');
  const [searchResults, setSearchResults] = useState([]);
  const [organisationZipcode, setOrganisationZipcode] = useState('')
  const [organisationStreet, setOrganisationStreet] = useState('')
  const [organisationCity, setOrganisationCity] = useState('')
  const [organisationEmployerName, setOrganisationEmployerName] = useState('')
  const [organisationSiret, setOrganisationSiret] = useState('')
  const [organisationLatitude, setOrganisationLatitude] = useState(0);
  const [organisationLongitude, setOrganisationLongitude] = useState(0);
  const [manualEnter, setManualEnter] = useState(false)

  const inputChange = (event) => {
    setSiret(event.target.value);
  };

  const searchCompanyBySiret = (siret) => {
    fetch(endpoints.searchCompanyBySiret({ siret }))
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
        if (longitude == 0 && latitude == 0) { console.log('coordinates are wrong') }
        setOrganisationLongitude(longitude);
        setOrganisationLatitude(latitude);
      });
  };

  const retrieveGeoPosition = (json) => {
    const coordinates = json.features[0].geometry.coordinates;
    return [parseFloat(coordinates[0]), parseFloat(coordinates[1])];
  }

  const downshiftWasUsed = () => {
    return (organisationZipcode != '')
  }

  const openTooggle = (event) => {
    event.preventDefault();
    setManualEnter(!manualEnter);
    console.log(manualEnter);
  }

  const splitAddressDetails = (selection) => {
    setOrganisationSiret(selection.siret);
    setOrganisationEmployerName(selection.uniteLegale.denominationUniteLegale);
    setOrganisationZipcode(selection.adresseEtablissement.codePostalEtablissement);
    setOrganisationCity(selection.adresseEtablissement.libelleCommuneEtablissement);
    const organisationStreet = `${selection.adresseEtablissement.numeroVoieEtablissement} ${selection.adresseEtablissement.typeVoieEtablissement} ${selection.adresseEtablissement.libelleVoieEtablissement} `;
    setOrganisationStreet(organisationStreet);
    searchCoordinatesByAddress(`${organisationStreet} ${organisationZipcode} ${organisationCity}`);
  }

  useEffect(() => {
    document.getElementById('siren-error').classList.add('d-none');
    //  a number ?
    if (/^(?=.*\d)[\d ]+$/.test(siret)) {
      const cleanSiret = siret.replace(/\s/g, '');

      if (cleanSiret.length === 14) {
        searchCompanyBySiret(cleanSiret);
      } else {
        setSearchResults([]);
      }
    // a text
    } else if (siret.length > 2) {
        searchCompanyByName(siret);
    }
  }, [siret]);


  return (
    <div className="form-group" id="input-siren">
      <div className="container-downshift">
        {
          (manualEnter) ?
          (<SimpleAddressInput
            resourceName={resourceName}
          />)
          :
          (downshiftWasUsed() ?
            (<CompanySummary
              organisationEmployerName={organisationEmployerName}
              organisationZipcode={organisationZipcode}
              organisationCity={organisationCity}
              organisationStreet={organisationStreet}
              organisationSiret={organisationSiret}
              organisationLatitude={organisationLatitude}
              organisationLongitude={organisationLongitude}
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
                        Rechercher votre société dans l’Annuaire des Entreprises {railsEnv === 'development' ? '(dev only : 90943224700015)' : ''}
                      </label>
                      <div className="input-group input-siren">
                        <input
                          {...getInputProps({
                            onChange: inputChange,
                            value: currentSiret,
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
      </div>
    </div>
  )
}
