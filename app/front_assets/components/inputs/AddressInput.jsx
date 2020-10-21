import React, { useEffect, useState } from 'react';
import { useDebounce } from 'use-debounce';
import Downshift from 'downshift';
import { fetch } from 'whatwg-fetch';

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
  const [fullAddressDebounced] = useDebounce(fullAddress, 100);

  const inputChange = (event) => {
    setFullAddress(event.target.value);
  };

  const toggleHelpVisible = () => {
    setHelpVisible(!helpVisible);
  };

  const searchCityByAddress = () => {
    const endpoint = new URL(
      `${document.location.protocol}//${document.location.host}/api_address_proxy/search`
    );
    const searchParams = new URLSearchParams();

    searchParams.append('q', fullAddress);
    searchParams.append('limit', 10);
    endpoint.search = searchParams.toString();

    fetch(endpoint)
      .then((response) => response.json())
      .then((json) => setSearchResults(json.features));
  };

  const setFullAddressComponents = (item) => {
    setFullAddress(item.properties.label);
    setStreet(
      [item.properties.housenumber, item.properties.street]
        .filter((component) => component)
        .join(' '),
    );
    setCity(item.properties.city);
    setZipcode(item.properties.postcode);
    setLatitude(parseFloat(item.geometry.coordinates[1]));
    setLongitude(parseFloat(item.geometry.coordinates[0]));
  };

  useEffect(() => {
    if (fullAddressDebounced && fullAddressDebounced.length > 2) {
      searchCityByAddress(fullAddressDebounced);
    }
  }, [fullAddressDebounced]);

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
              selectedItem,
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
                  <a className="btn-absolute btn btn-link py-0" onClick={toggleHelpVisible}>
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
                      id: 'internship_offer_autocomplete',
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
                      {isOpen
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
                                  fontWeight: selectedItem === item ? 'bold' : 'normal',
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
        <div className={`${helpVisible ? '' : 'd-none'} my-1 p-2 help-sign-content`}>
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
