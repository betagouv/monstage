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
  labelName,
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
  const [formerSearchResults, setFormerSearchResults] = useState([]);
  const [queryString, setQueryString] = useState('');
  const [fullAddressDebounced] = useDebounce(fullAddress, 100);

  const inputChange = (event) => {
    document.getElementById(`${resourceName}_street_complement`).value = '';
    setFullAddress(event.target.value);
  };

  const toggleHelpVisible = (event) => {
    event.stopPropagation();
    setHelpVisible(!helpVisible);
  };
  const searchCityByAddress = () => {
    fetch(endpoints.apiSearchAddress({ fullAddress }))
      .then((response) => response.json())
      .then((json) => {
        setFormerSearchResults(searchResults);
        setSearchResults(json.features.length === 0 ? formerSearchResults : json.features);
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
      );
    };
    setCity(item.properties.city);
    setZipcode(item.properties.postcode);
    setLatitude(parseFloat(item.geometry.coordinates[1]));
    setLongitude(parseFloat(item.geometry.coordinates[0]));
  };

  useEffect(() => {
    if (fullAddressDebounced && fullAddressDebounced.length > 2) {
      searchCityByAddress();
    }
  }, [fullAddressDebounced]);

  useEffect(() => {
    broadcast(newCoordinatesChanged({ latitude, longitude }));
  }, [latitude, longitude]);

  return (
    <>
      <div className="form-group" id={`test-input-full-address-${resourceName}`}>


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
                <div className="fr-callout d-none">
                  <p className="fr-callout__text">
                    L'adresse postale est pré-remplie automatiquement lors du choix de l'entreprise. Vous pouvez cependant modifier cette adresse si elle ne correspond pas à l'adresse postale où le stage se déroulera.
                  </p>
                </div>
                <label
                  {...getLabelProps({
                    className: 'label',
                    htmlFor: `${resourceName}_autocomplete`,
                  })}
                >
                  {labelName || 'Adresse'}
                  <abbr title="(obligatoire)" aria-hidden="true">
                    *
                  </abbr>
                  <a
                    className="btn-absolute btn btn-link py-0 fr-raw-link"
                    href={`#help-multi-location-${resourceName}`}
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
                      className: 'fr-input',
                      name: `${resourceName}_autocomplete`,
                      id: `${resourceName}_autocomplete`,
                      placeholder: 'Adresse',
                      "data-organisation-form-target": 'requiredField'
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
                      {isOpen && (queryString === fullAddress) && ((searchResults.length > 0)) ?
                        searchResults.map((item, index) => (
                          <li
                            {...getItemProps({
                              className: `py-2 px-3 listview-item ${highlightedIndex === index ? 'highlighted-listview-item' : '' }`,
                              key: `${item.properties.id}-${item.properties.label}`,
                              index,
                              item,
                              style: { fontWeight: highlightedIndex === index ? 'bold' : 'normal', },
                            })}
                          >
                            {item.properties.label}
                          </li>
                        ))
                        : (isOpen && (queryString === fullAddress) || (formerSearchResults.length === 0)) ?
                          null
                          : isOpen && formerSearchResults.map((item, index) => (
                          <li
                            {...getItemProps({
                              className: `py-2 px-3 listview-item ${highlightedIndex === index ? 'highlighted-listview-item' : '' }`,
                              key: `${item.properties.id}-${item.properties.label}`,
                              index,
                              item,
                              style: { fontWeight: highlightedIndex === index ? 'bold' : 'normal', },
                            })}
                          >
                            {item.properties.label}
                          </li>
                        ))
                      }
                    </ul>
                  </div>
                </div>
              </div>
            )}
          </Downshift>
        </div>
        <div
          id={`help-multi-location-${resourceName}`}
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
              Rue
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
            <input
              className="fr-input"
              value={street}
              readOnly
              type="text"
              name={`${resourceName}[street]`}
              id={`${resourceName}_street`}
              data-organisation-form-target="requiredField"
            />
          </div>
        </div>
      </div>
      <div className="form-row">
        <div className="col-sm-12">
          <div className="form-group">
            <label htmlFor={`${resourceName}_street_complement`}>
              Complément d'adresse
            </label>
            <input
              className="fr-input"
              type="text"
              name={`${resourceName}[street_complement]`}
              id={`${resourceName}_street_complement`}
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
              className="fr-input"
              required="required"
              value={city}
              type="text"
              readOnly
              name={`${resourceName}[city]`}
              id={`${resourceName}_city`}
              data-organisation-form-target="requiredField"
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
              className="fr-input"
              required="required"
              value={zipcode}
              type="text"
              name={`${resourceName}[zipcode]`}
              id={`${resourceName}_zipcode`}
              readOnly
              data-organisation-form-target="requiredField"
            />
          </div>
        </div>
      </div>
    </>
  );
}
