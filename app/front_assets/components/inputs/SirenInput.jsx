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
  railsEnv
}) {
  const [siret, setSiret] = useState(currentSiret || '');
  const [searchResults, setSearchResults] = useState([]);
  const [selectedCompany, setSelectedCompany] = useState(null);

  const inputChange = (event) => {
    setSelectedCompany(null);
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

  const openManual = (event) => {
    event.preventDefault();
    const blocs = document.querySelectorAll('.bloc-tooggle');
    blocs.forEach(bloc => {
      bloc.classList.remove('d-none');
    });
    const manualBlocs = document.querySelectorAll('.bloc-manual');
    manualBlocs.forEach(bloc => {
      bloc.classList.remove('d-none');
    });
    document.querySelector('.fr-callout').classList.add('d-none');
    document.getElementById('organisation_city').removeAttribute("readonly");
    document.getElementById('organisation_zipcode').removeAttribute("readonly");
    document.getElementById("organisation_manual_enter").value = true;
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
            setSelectedCompany({
              name: selection.uniteLegale.denominationUniteLegale,
              zipcode: zipcode,
              city: city,
              street: street,
              siret: selection.siret,
            });
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
                    className: 'fr-label',
                    htmlFor: `${resourceName}_siren`,
                  })}
                >
                  Rechercher votre société/administration dans l’annuaire des entreprises {railsEnv === 'development' ? '(dev only : 90943224700015)' : ''}
                </label>
                <div className="input-group input-siren">
                  <input
                    {...getInputProps({
                      onChange: inputChange,
                      value: currentSiret,
                      className: 'fr-input',
                      id: `${resourceName}_siren`,
                      placeholder: 'Rechercher un nom ou un SIRET',
                      name: `${resourceName}[siren]`
                    })}
                  />
                </div>
                <div className='mt-2 d-flex align-items-center'>
                  <small><span className="fr-icon-info-fill text-blue-info" aria-hidden="true"></span></small>
                  <small className="text-blue-info fr-mx-1w">Société introuvable ?</small>
                  <a href='#manual-input' className='pl-2 small text-blue-info' onClick={openManual}>Ajouter une société manuellement</a>
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
                                className: `fr-px-2w fr-py-2w listview-item ${
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
                              <p className='fr-my-0 text-dark font-weight-bold'>
                                {item.uniteLegale.denominationUniteLegale}
                              </p>
                              <p className='fr-my-0 fr-text--sm text-dark'>
                                {item.activite}
                              </p>
                              <p className='fr-my-0 fr-text--sm text-dark'>
                                {item.adresseEtablissement.adresseCompleteEtablissement}
                              </p>
                            </li>
                      ))
                      : null}
                  </ul>
                </div>
              </div>

              { 
                selectedCompany && (
                  <div className='mt-2 d-flex'>
                    <div className="fr-highlight">
                      <p className='fr-my-0'>{selectedCompany.name}</p>
                      <p className='fr-my-0'>{selectedCompany.street}</p>
                      <p className='fr-my-0'>{selectedCompany.city}, {selectedCompany.zipcode}</p>
                      <p className='fr-my-0'>SIRET : {selectedCompany.siret}</p>
                    </div>
                  </div>
                )
              }
            </div>
          )}
        </Downshift>
      </div>
    </div>
  )
}
