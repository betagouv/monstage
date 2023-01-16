import React, { useEffect, useState } from 'react';
import { useDebounce } from 'use-debounce';
// import { throttle, debounce } from "throttle-debounce";
import Downshift from 'downshift';
import { fetch } from 'whatwg-fetch';
import { endpoints } from '../../utils/api';

// see: https://geo.api.gouv.fr/adresse
export default function SirenInput({
  resourceName,
  currentSiret,
  currentCity,
  currentStreet,
  currentZipcode,
  currentEmployerName,
  railsEnv
}) {
  const [siret, setSiret] = useState(currentSiret || '');
  const [searchResults, setSearchResults] = useState([]);
  const [organisationZipcode, setOrganisationZipcode] = useState(currentZipcode || '')
  const [organisationStreet, setOrganisationStreet] = useState(currentStreet ||  '')
  const [organisationCity, setOrganisationCity] = useState(currentCity || '')
  const [organisationEmployerName, setOrganisationEmployerName] = useState(currentEmployerName || '')
  const [organisationSiret, setOrganisationSiret] = useState(currentSiret || '')
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
        const coordinates = json.features[0].geometry.coordinates;
        document.getElementById("organisation_coordinates_longitude").value = coordinates[0];
        document.getElementById("organisation_coordinates_latitude").value = coordinates[1];
      });
  };

  const openTooggle = (event) => {
    event.preventDefault();
    const blocs = document.querySelectorAll('.bloc-tooggle');
    blocs.forEach(bloc => {
      bloc.classList.remove('d-none');
    });
    document.querySelector('.fr-callout').classList.add('d-none');
    document.getElementById('organisation_city').removeAttribute("readonly");
    document.getElementById('organisation_zipcode').removeAttribute("readonly");
    document.getElementById("organisation_manual_enter").value = true;
  }

  useEffect(() => {
    const elem_error = document.getElementById('siren-error');
    if (elem_error) { elem_error.classList.add('d-none'); }
    //  a number ?
    if (/^(?=.*\d)[\d ]+$/.test(siret)) {
      const cleanSiret = siret.replace(/\s/g, '');

      if (cleanSiret.length === 14) {
        searchCompanyBySiret(cleanSiret);
      } else {
        setSearchResults([]);
      }
    // a text 
    } else {
      if (siret.length > 2) {
        searchCompanyByName(siret);
      }
    }
  }, [siret]);


  return (
    <div className="form-group" id="input-siren">
      <div className="container-downshift">
        <Downshift
          onChange={selection => {
            const blocs = document.querySelectorAll('.bloc-tooggle');
              blocs.forEach(bloc => {
                bloc.classList.remove('d-none');
              });
            document.getElementById("organisation_employer_name").value = selection.uniteLegale.denominationUniteLegale;
            const zipcode = selection.adresseEtablissement.codePostalEtablissement;
            const city = selection.adresseEtablissement.libelleCommuneEtablissement;
            const street = `${selection.adresseEtablissement.numeroVoieEtablissement} ${selection.adresseEtablissement.typeVoieEtablissement} ${selection.adresseEtablissement.libelleVoieEtablissement} `;
            const fullAddress = `${street} ${zipcode} ${city}`;
            document.getElementById("organisation_autocomplete").value = fullAddress;
            document.getElementById("organisation_street").value = street;
            document.getElementById("organisation_city").value = city;
            document.getElementById("organisation_zipcode").value = zipcode;
            document.getElementById("organisation_siret").value = selection.siret;
            searchCoordinatesByAddress(fullAddress);
            }
          }
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
                                className: `py-2 px-3 listview-item ${
                                  highlightedIndex === index ? 'highlighted-listview-item' : ''
                                }`,
                                key: index,
                                index,
                                item,
                                style: {
                                  fontWeight: highlightedIndex === index? 'bold' : 'normal',
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
      </div>
    </div>
  )
}
