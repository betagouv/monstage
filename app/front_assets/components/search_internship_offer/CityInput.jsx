import React, { useEffect, useState } from 'react';
import { useDebounce } from 'use-debounce';
import Downshift from 'downshift';
import focusedInput from './FocusedInput';
import RadiusInput from './RadiusInput';
import { fetch } from 'whatwg-fetch';

const COMPONENT_FOCUS_LABEL = 'location';

// see: https://geo.api.gouv.fr/decoupage-administratif/communes 
// and
// 'https://geo.api.gouv.fr/communes?codePostal=78000' --> code curl
// 'https://geo.api.gouv.fr/communes?code=78646&fields=code,nom,codesPostaux,code

function CityInput({
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
  // getters
  city: cityOrZipcode
}) {
  const [searchResults, setSearchResults] = useState([]);
  const [cityDebounced] = useDebounce(cityOrZipcode, 100);
  const inputChange = (event) => {
    setCity(event.target.value);
  };
  const endpoint = new URL('https://geo.api.gouv.fr/communes');
  const setLocation = (item) => {
    if (item) {
      setCity(item.nom);
      setLatitude(item.centre.coordinates[1]);
      setLongitude(item.centre.coordinates[0]);
    }
  };

  const isZipcode = (str) => {
    return (str.length == 5 && !isNaN(str))
  }

  const searchCityByNameOrByZipcode = () => {
    isZipcode(cityOrZipcode) ? searchByZipcode(cityOrZipcode) : searchCityByName(cityOrZipcode);
  };

  const searchCityByName = () => {
    const searchParams = new URLSearchParams();

    searchParams.append('nom', cityOrZipcode);
    searchParams.append('fields', ['nom', 'centre', 'departement', 'codesPostaux'].join(','));
    searchParams.append('limit', 10);
    searchParams.append('boost', 'population');
    endpoint.search = searchParams.toString();
    fetch(endpoint)
      .then((response) => response.json())
      .then(setSearchResults);
  };
  // zipcodes represent a set of communes referenced with a code. 
  // This set represents an area that have a center from which a radius can be used for other search criteria
  const searchByZipcode = (zipcode) => {
    const searchParams = new URLSearchParams();

    searchParams.append('codePostal', zipcode);
    endpoint.search = searchParams.toString();

    fetch(endpoint)
      .then((response) => response.json())
      .then((jsonResponse) => searchByCode(jsonResponse[0]))
  };

  const searchByCode = (responseWithCode) => {
    if (responseWithCode == undefined || responseWithCode.code == undefined) {
      setCity(cityOrZipcode + " : code postal invalide")
    } else {
      const code = responseWithCode.code
      const searchParams = new URLSearchParams();

      searchParams.append('code', code);
      searchParams.append('nom', responseWithCode.nom);
      searchParams.append('fields', ['nom', 'centre', 'departement', 'codesPostaux', 'code'].join(','));
      searchParams.append('limit', 10);
      searchParams.append('boost', 'population');
      endpoint.search = searchParams.toString();

      fetch(endpoint)
        .then((response) => response.json())
        .then(setSearchResults);
    }
  };

  const codePostauxSample = (codes) => {
    let zipcode = ""
    if (codes.length == undefined || codes.length === 0) { return zipcode; }
    if (codes.length >= 1) { zipcode = codes[0]; }
    if (codes.length >= 2) { zipcode += ", " + codes[1]; }
    if (codes.length > 2) { zipcode += ", ... " }
    return `(${zipcode})`;
  };

  useEffect(() => {
    if (cityDebounced && cityDebounced.length > 2) {
      searchCityByNameOrByZipcode(cityDebounced);
    }
  }, [cityDebounced]);

  return (
    <Downshift
      initialInputValue={cityOrZipcode || ""}
      onChange={setLocation}
      selectedItem={cityOrZipcode}
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
        openMenu
      }) => (
        <div
          id="test-input-location-container"
          title="Résultat de recherche"
          className={`input-group input-group-search col ${focusedInput({
            check: COMPONENT_FOCUS_LABEL,
            focus,
          })}`}
        >
          <div className="input-group-prepend ">
            <label
              {...getLabelProps()}
              className="input-group-text input-group-text-bigger input-group-separator"
              htmlFor="input-search-by-city-or-zipcode"
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
              name: 'cityOrZipcode',
              id: 'input-search-by-city-or-zipcode',
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
                "aria-labelledby": 'input-search-by-city-or-zipcode',
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
                      className: `py-2 px-3 listview-item ${highlightedIndex === index ? 'highlighted-listview-item' : ''}`,
                      key: item.code,
                      index,
                      item,
                      style: {
                        fontWeight: selectedItem === item ? 'bold' : 'normal',
                      },
                    })}
                  >
                    {`${item.nom} ${codePostauxSample(item.codesPostaux)}`}
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

export default CityInput;
