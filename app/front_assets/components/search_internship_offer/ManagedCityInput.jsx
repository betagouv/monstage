import React, { useEffect, useState } from 'react';
import { useDebounce } from 'use-debounce';
import Downshift from 'downshift';
import focusedInput from './FocusedInput';
import RadiusInput from './RadiusInput';
import { fetch } from 'whatwg-fetch';

const COMPONENT_FOCUS_LABEL = 'location';


// see: https://geo.api.gouv.fr/decoupage-administratif/communes

function ManagedCityInput({
  // getters
  city,
  // setters
  setCity,
  setLatitude,
  setLongitude,
  // forwarded to radiusInput
  radius,
  setRadius,
  // used by container
  focus,
  setFocus,
}) {
  const [searchResults, setSearchResults] = useState([]);
  const [cityDebounced] = useDebounce(city, 100);
  const inputChange = (event) => {
    setCity(event.target.value);
  };

  const setLocation = (item) => {
    if (item) {
      setCity(item.nom);
      setLatitude(item.centre.coordinates[1]);
      setLongitude(item.centre.coordinates[0]);
    }
  };

  const searchCityByName = () => {
    const endpoint = new URL('https://geo.api.gouv.fr/communes');
    const searchParams = new URLSearchParams();

    searchParams.append('nom', city);
    searchParams.append('fields', ['nom', 'centre', 'departement', 'codesPostaux'].join(','));
    searchParams.append('limit', 10);
    searchParams.append('boost', 'population');
    endpoint.search = searchParams.toString();

    fetch(endpoint)
      .then((response) => response.json())
      .then(setSearchResults);
  };

  const codePostauxSample = (codes) => {
    let zipcode = ""
    if (codes.length == undefined || codes.length === 0) { return zipcode; }
    if (codes.length >= 1) { zipcode = codes[0]; }
    // TODO remove following comments after october 2021
    // if (codes.length >= 2) { zipcode += ", " + codes[1]; }
    // if (codes.length > 2) { zipcode += ", ... " }
    return zipcode
  };

  useEffect(() => {
    if (cityDebounced && cityDebounced.length > 2) {
      searchCityByName(cityDebounced);
    }
  }, [cityDebounced]);

  return (
    <Downshift
      initialInputValue={city || ""}
      onChange={setLocation}
      selectedItem={city}
      itemToString={(item) => (item ? item.nom : '')}
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
        openMenu,
      }) => (
        <div
          id="test-input-location-container"
          title="Resulltat de recherche"
          className={`input-group input-group-search col ${focusedInput({
            check: COMPONENT_FOCUS_LABEL,
            focus,
          })}`}
        >
          <div className="input-group-prepend ">
            <label
              {...getLabelProps()}
              className="input-group-text input-group-text-bigger input-group-separator"
              htmlFor="input-search-by-city"
            >
              <i className="fas fa-map-marker-alt fa-fw" />
              <strong className="d-none">Autour de</strong>
            </label>
          </div>

          <input
            {...getInputProps({
              onChange: inputChange,
              value: inputValue,
              className: 'form-control pl-2 input-group-search-right-border',
              name: 'city',
              id: 'input-search-by-city',
              placeholder: 'Lieu',
              "aria-label": "Autour de",
              onFocus: (event) => {
                setFocus(COMPONENT_FOCUS_LABEL);
                openMenu(event);
              },
            })}
          />

          <div className="search-in-place bg-white shadow">
            <ul
              {...getMenuProps({
                className: 'p-0 m-0',
                "aria-labelledby": 'input-search-by-city',
              })}
            >
              {(isOpen || focus == COMPONENT_FOCUS_LABEL) && (
                <li>
                  <RadiusInput radius={radius} setRadius={setRadius} focus={focus} setFocus={setFocus} />
                </li>
              )}
              {isOpen
                ? searchResults.map((item, index) => (
                  <li
                    {...getItemProps({
                      className: `py-2 px-3 listview-item ${highlightedIndex === index ? 'highlighted-listview-item' : ''
                        }`,
                      key: item.code,
                      index,
                      item,
                      style: {
                        fontWeight: selectedItem === item ? 'bold' : 'normal',
                      },
                    })}
                  >
                    {`${item.nom} (${codePostauxSample(item.codesPostaux)})`}
                  </li>
                ))
                : null}
            </ul>
          </div>
        </div>
      )}
    </Downshift>
  );
}

export default ManagedCityInput;
