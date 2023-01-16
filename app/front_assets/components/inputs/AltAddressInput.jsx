import React, { useEffect, useState } from 'react';
import { useDebounce } from 'use-debounce';
// import { throttle, debounce } from "throttle-debounce";
import Downshift from 'downshift';
import { fetch } from 'whatwg-fetch';
import CompanySummary from '../CompanySummary';
import { endpoints } from '../../utils/api';
import SimpleAddressInput from './SimpleAddressInput';
import { broadcast, newCoordinatesChanged } from '../../utils/events';

// see: https://geo.api.gouv.fr/adresse
export default function AltAddressInput({
  resourceName,
  employerName,
  addressTypeLabel
}) {
  const [helpVisible, setHelpVisible] = useState(false);
  const [fullAddress, setFullAddress] = useState('');
  const [street, setStreet] = useState('');
  const [city, setCity] = useState('');
  const [zipcode, setZipcode] = useState('');
  const [latitude, setLatitude] = useState(0);
  const [longitude, setLongitude] = useState(0);
  const [searchResults, setSearchResults] = useState([]);
  const [queryString, setQueryString] = useState('');
  const [manualEnter, setManualEnter] = useState(false)
  const [fullAddressDebounced] = useDebounce(fullAddress, 100);

  const inputChange = (event) => {
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
      );
    };
    setCity(item.properties.city);
    setZipcode(item.properties.postcode);
    setGeoPosition(item);
  };

  useEffect(() => {
    if (fullAddressDebounced && fullAddressDebounced.length > 2) {
      searchCityByAddress()
    }
  }, [fullAddressDebounced]);

  useEffect(() => {
    broadcast(newCoordinatesChanged({ latitude, longitude }));
  }, [latitude, longitude]);

  useEffect(() => {
    if (!manualEnter) { return }
    if (!isAddressCompleted()) { return }
    
    // manual with completed address only
    const address = `${street} ${zipcode} ${city}`;
    setFullAddress(address);
    setQueryString(address);

    fetch(endpoints.apiSearchAddress({ fullAddress: address }))
      .then((response) => response.json())
      .then((json) => { setGeoPositionOutOfMany(json); });

  }, [street, zipcode, city]);

  // private methods -----------------

  const setGeoPosition = (item) => {
    let [longitude, latitude] = [0, 0];
    if (item && item.geometry) {
      [longitude, latitude] = parseCoordinates(item.geometry.coordinates);
    }
    setLongitude(longitude);
    setLatitude(latitude);
    return;
  }

  const setGeoPositionOutOfMany = (item) => {
    // taking the first result into account
    const addressResult = item.features[0];
    let [longitude ,latitude] = [0, 0];
    if ((addressResult) && (addressResult.geometry != undefined) && (addressResult.properties.score > 0.9)) {
      [longitude, latitude] = parseCoordinates(addressResult.geometry.coordinates);
    }
    setLongitude(longitude);
    setLatitude(latitude);
    return;
  }

  const parseCoordinates = (coordinates) => { return [parseFloat(coordinates[0]), parseFloat(coordinates[1])] }

  const setPristineSearch = () => {
    setZipcode('');
    setStreet('');
    setCity('');
  }

  const isAddressCompleted = () => { return (zipcode!='') && (zipcode.length > 4) && (city!='') && (street!=''); };
  const downshiftWasUsed = () => { return (zipcode != '') }
  const openTooggle = (event) => { event.preventDefault(); setManualEnter(!manualEnter); setPristineSearch(); }
  const resetSearch = (event) => { event.preventDefault(); setPristineSearch(); }
  //----------------- private methods

  return (
    <div>
      <div className="form-group" id="test-input-full-address">
        <div className="container-downshift">
          {
            (manualEnter) ?
              (<SimpleAddressInput
                addressTypeLabel={addressTypeLabel}
                withEmployerName={false}
                resourceName={resourceName}
                zipcode={zipcode}
                city={city}
                street={street}
                setZipcode={setZipcode}
                setCity={setCity}
                setStreet={setStreet}
              />)
              :
              (downshiftWasUsed() ?
                (<CompanySummary
                  resourceName={resourceName}
                  addressTypeLabel = {addressTypeLabel}
                  employerName={employerName}
                  zipcode={zipcode}
                  city={city}
                  street={street}
                  resetSearch={resetSearch}
                />)
                :
                (
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
                          {addressTypeLabel}
                          <abbr title="(obligatoire)" aria-hidden="true">
                            *
                          </abbr>
                          <a
                            className="btn-absolute btn fr-btn btn-link py-0"
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
                        <div className='mt-2 d-flex'>
                          <small className="text-muted">Société introuvable ?</small>
                          <a href='#manual-input' className='pl-2 small' onClick={openTooggle}>Ajouter une société manuellement</a>
                        </div>
                        <div>
                          <div className="search-in-place bg-white shadow">
                            <ul
                              {...getMenuProps({
                                className: 'p-0 m-0',
                              })}
                            >
                              {isOpen && queryString === fullAddress
                                ? searchResults.map((item, index) => (
                                  <li
                                    {...getItemProps({
                                      className: `py-2 px-3 listview-item ${highlightedIndex === index ? 'highlighted-listview-item' : ''
                                        }`,
                                      key: `${item.properties.id}-${item.properties.label}`,
                                      index,
                                      item,
                                      style: {
                                        fontWeight: highlightedIndex === index ? 'bold' : 'normal',
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
                )
              )
          }
        </div>
        <div
          id="help-multi-location"
          className={`${helpVisible ? '' : 'd-none'} my-1 p-2 help-sign-content`}
        >
          Si vous proposez le même stage dans un autre établissement, déposez une offre par
          établissement. Si le stage est itinérant (la semaine se déroule sur plusieurs lieux),
          indiquez l'adresse où l'élève devra se rendre au premier jour
        </div>
        <div>
          <input type='hidden' name={`${resourceName}[manual_enter]`} id={`${resourceName}_manual_enter`} value={manualEnter} />
          <input type='hidden' name={`${resourceName}[coordinates][longitude]`} id={`${resourceName}_coordinates_longitude`} value={longitude} />
          <input type='hidden' name={`${resourceName}[coordinates][latitude]`} id={`${resourceName}_coordinates_latitude`} value={latitude} />
          <input type='hidden' name={`${resourceName}[employer_name]`} id={`${resourceName}_employer_name`} value={employerName} />
          <input type='hidden' name={`${resourceName}[street]`} id={`${resourceName}_street`} value={street.trim()} />
          <input type='hidden' name={`${resourceName}[city]`} id={`${resourceName}_city`} value={city.trim()} />
          <input type='hidden' name={`${resourceName}[zipcode]`} id={`${resourceName}_zipcode`} value={zipcode.trim()} />
        </div>
      </div>
    </div>
  );
}
