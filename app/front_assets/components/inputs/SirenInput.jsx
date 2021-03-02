import React, { useEffect, useState } from 'react';
import { useDebounce } from 'use-debounce';
// import { throttle, debounce } from "throttle-debounce";
import Downshift from 'downshift';
import { fetch } from 'whatwg-fetch';
import { endpoints } from '../../utils/api';

// see: https://geo.api.gouv.fr/adresse
export default function SirenInput({
  resourceName,
  currentSiren
}) {
  const [siren, setSiren] = useState(currentSiren || '');
  const [searchResults, setSearchResults] = useState([]);
  const [sirenDebounced] = useDebounce(siren, 100);

  const inputChange = (event) => {
    setSiren(event.target.value);
  };

  const searchCompanyBySiren = (siren) => {
    fetch(endpoints.searchCompanyBySiren({ siren }))
      .then((response) => response.json())
      .then((json) => {
        if (json.etablissements !== undefined) {
          setSearchResults(json.etablissements);
        } else {
          setSearchResults([])
        }
      });
  };

  useEffect(() => {
    const clean_siren = siren.replace(/\s/g, '');
    if (clean_siren.length === 9) {
      searchCompanyBySiren(clean_siren);
    } else {
      setSearchResults([]);
    }
  }, [siren]);


  return (
    <div className="form-group" id="test-input-full-address">
      <div className="container-downshift">
        <Downshift
          onChange={selection => {
            document.getElementById("organisation_employer_name").value = selection.uniteLegale.denominationUniteLegale;
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
              <label
                {...getLabelProps({
                  className: 'label',
                  htmlFor: `${resourceName}_siren`,
                })}
              >
                Indiquez votre numéro Siren pour faciliter la saisie
              </label>

              <div className="form-group custom-label-container">
                <div className="input-group">
                  <input
                    {...getInputProps({
                      onChange: inputChange,
                      value: currentSiren,
                      className: 'form-control rounded-0',
                      id: `${resourceName}_siren`,
                      placeholder: '123 456 789',
                      name: `${resourceName}[siren]`
                    })}
                  />
                </div>
              </div>
              <div>
                <div className="search-in-place bg-white shadow">
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
                                key: item.siret,
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
