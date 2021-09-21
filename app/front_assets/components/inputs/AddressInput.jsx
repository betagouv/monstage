import React, { useEffect, useState } from 'react';
import { useDebounce } from 'use-debounce';
// import { throttle, debounce } from "throttle-debounce";
import Downshift from 'downshift';
import { fetch } from 'whatwg-fetch';
import { endpoints } from '../../utils/api';
import { broadcast, newCoordinatesChanged } from '../../utils/events';

// see: https://geo.api.gouv.fr/adresse
export default function AddressInput({
  resourceName,
  currentStreet,
  currentCity,
  currentZipcode,
  currentLatitude,
  currentLongitude,
  currentFullAddress,
}) {
  const [helpVisible, setHelpVisible] = useState(false);
  const [fullAddress, setFullAddress] = useState(currentFullAddress || '');
  const [street, setStreet] = useState(currentStreet || '');
  const [city, setCity] = useState(currentCity || '');
  const [zipcode, setZipcode] = useState(currentZipcode || '');
  const [latitude, setLatitude] = useState(currentLatitude || 0);
  const [longitude, setLongitude] = useState(currentLongitude || 0);
  const [searchResults, setSearchResults] = useState([]);
  const [queryString, setQueryString] = useState('');
  const [fullAddressDebounced] = useDebounce(fullAddress, 100);

  const inputChange = (event) => {
    setFullAddress(event.target.value);
  };

  const toggleHelpVisible = () => {
    setHelpVisible(!helpVisible);
  };
  const searchCityByAddress = () => {
    fetch(endpoints.apiSearchAddress({ fullAddress }))
      .then((response) => response.json())
      .then((json) => {
        setSearchResults(json.features)
        setQueryString(json.query)
      });
  };

  const setFullAddressComponents = (item) => {
    setFullAddress(item.properties.label);
    if (item.properties.housenumber === undefined) {
      setStreet(item.properties.name);
    } else {
      setStreet(
        [item.properties.housenumber, item.properties.street]
          .filter((component) => component)
          .join(' ')
      )
    };
    setCity(item.properties.city);
    setZipcode(item.properties.postcode);
    setLatitude(parseFloat(item.geometry.coordinates[1]));
    setLongitude(parseFloat(item.geometry.coordinates[0]));
  };

  useEffect(() => {
    if (fullAddressDebounced && fullAddressDebounced.length > 2) {
      searchCityByAddress()
    }
  }, [fullAddressDebounced]);

  useEffect(() => {
    broadcast(newCoordinatesChanged({ latitude, longitude }));
  }, [latitude, longitude]);

  return (
    <div>
      <div className="form-group" id="test-input-full-address">
        <div className="container-downshift">
          <Downshift
            initialInputValue={fullAddress}
            onChange={setFullAddressComponents}
            selectedItem={fullAddress}
            itemToString={(item) => {
              item && item.properties ? item.properties.label : '';
            }}
          >
            {({
              getLabelProps,
              getInputProps,
              getItemProps,
              getMenuProps,
              isOpen,
              highlightedIndex,
            }) => (
              <div>
                <label
                  {...getLabelProps({
                    className: 'label',
                    htmlFor: `${resourceName}_autocomplete`,
                  })}
                >
                  Adresse du lieu où se déroule le stage
                  <abbr title="(obligatoire)" aria-hidden="true">
                    *
                  </abbr>
                  <a
                    className="btn-absolute btn btn-link py-0"
                    href="#help-multi-location"
                    aria-label="Afficher l'aide"
                    onClick={toggleHelpVisible}
                  >
                    <i className="fas fa-question-circle" />
                  </a>
                </label>

                <div>
                  <input
                    {...getInputProps({
                      onChange: inputChange,
                      value: fullAddress,
                      className: 'form-control',
                      name: `${resourceName}_autocomplete`,
                      id: `${resourceName}_autocomplete`,
                      placeholder: 'Adresse',
                    })}
                  />
                </div>
                <div>
                  <div className="search-in-place bg-white shadow">
                    <ul
                      {...getMenuProps({
                        className: 'p-0 m-0',
                      })}
                    >
                      { isOpen && queryString === fullAddress
                        ? searchResults.map((item, index) => (
                            <li
                              {...getItemProps({
                                className: `py-2 px-3 listview-item ${
                                  highlightedIndex === index ? 'highlighted-listview-item' : ''
                                }`,
                                key: `${item.properties.id}-${item.properties.label}`,
                                index,
                                item,
                                style: {
                                  fontWeight: highlightedIndex === index? 'bold' : 'normal',
                                },
                              })}
                            >
                              {item.properties.label}
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
        <div
          id="help-multi-location"
          className={`${helpVisible ? '' : 'd-none'} my-1 p-2 help-sign-content`}
        >
          Si vous proposez le même stage dans un autre établissement, déposez une offre par
          établissement. Si le stage est itinérant (la semaine se déroule sur plusieurs lieux),
          indiquez l'adresse où l'élève devra se rendre au premier jour
        </div>
        <input
          id={`${resourceName}_coordinates_latitude`}
          value={latitude}
          name={`${resourceName}[coordinates][latitude]`}
          type="hidden"
        />
        <input
          id={`${resourceName}_coordinates_longitude`}
          value={longitude}
          name={`${resourceName}[coordinates][longitude]`}
          type="hidden"
        />
      </div>
      <div className="form-row">
        <div className="col-sm-12">
          <div className="form-group">
            <label htmlFor={`${resourceName}_street`}>
              Rue ou compléments d'adresse
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
            <input
              className="form-control"
              value={street}
              onChange={(event) => {
                console.log('set street va etre déclanché');
                setStreet(event.target.value);
              }}
              required="required"
              type="text"
              name={`${resourceName}[street]`}
              id={`${resourceName}_street`}
            />
          </div>
        </div>
        <div className="col-sm-12">
          <div className="form-group">
            <label htmlFor={`${resourceName}_city`}>
              Ville
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
            <input
              className="form-control"
              required="required"
              value={city}
              type="text"
              readOnly
              name={`${resourceName}[city]`}
              id={`${resourceName}_city`}
            />
          </div>
        </div>
        <div className="col-sm-12">
          <div className="form-group">
            <label htmlFor={`${resourceName}_zipcode`}>
              Code postal
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
            <input
              className="form-control"
              required="required"
              value={zipcode}
              type="text"
              name={`${resourceName}[zipcode]`}
              id={`${resourceName}_zipcode`}
              readOnly
            />
          </div>
        </div>
      </div>
    </div>
  );
}
