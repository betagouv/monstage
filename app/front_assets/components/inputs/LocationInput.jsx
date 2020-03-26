import React, { useEffect, useState } from 'react';
import Downshift from 'downshift';
import focusedInput from './FocusedInput';
import RadiusInput from './RadiusInput';

const COMPONENT_FOCUS_LABEL = 'location'
const buildValue = (searchTerm, radius) => searchTerm; // `${searchTerm} – ${radius / 1000}km`;

function LocationInput({
  setRadius,
  radius,
  initialRadius,
  setLocation,
  initialLocation,
  focus,
  setFocus,
}) {
  const [searchTerm, setSearchTerm] = useState(null);
  const [searchResults, setSearchResults] = useState([]);

  const inputChange = event => {
    setSearchTerm(event.target.value);
  };

  const searchCityByName = () => {
    const endpoint = new URL('https://geo.api.gouv.fr/communes');
    const searchParams = new URLSearchParams();

    searchParams.append('nom', searchTerm);
    searchParams.append('fields', ['nom', 'centre', 'departement', 'codesPostaux'].join(','));
    searchParams.append('limit', 10);
    searchParams.append('boost', 'population');
    endpoint.search = searchParams.toString();

    fetch(endpoint)
      .then(response => response.json())
      .then(setSearchResults);
  };

  useEffect(() => {
    if (searchTerm && searchTerm.length > 0 && searchTerm != initialLocation) {
      searchCityByName(searchTerm);
    }
  }, [searchTerm]);

  return (
    <Downshift
      initialInputValue={initialLocation ? buildValue(initialLocation, radius) : ''}
      onChange={setLocation}
      itemToString={item => (item ? buildValue(item.nom, radius) : '')}
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
              id: 'input-search-by-city',
              placeholder: 'Lieu',
              onFocus: (event) => {
                setFocus(COMPONENT_FOCUS_LABEL)
                openMenu(event)
              }
            })}
          />

          <div className="search-in-place bg-white shadow">
            <ul
              {...getMenuProps({
                className: 'p-0 m-0',
              })}
            >
              {isOpen &&  <li><RadiusInput radius={radius} setRadius={setRadius}/></li>}
              {isOpen
                ? searchResults.map((item, index) => (
                    <li
                      {...getItemProps({
                        className: `py-2 px-3 listview-item ${
                          highlightedIndex === index ? 'highlighted-listview-item' : ''
                        }`,
                        key: item.code,
                        index,
                        item,
                        style: {
                          fontWeight: selectedItem === item ? 'bold' : 'normal',
                        },
                      })}
                    >
                      {`${item.nom} (${
                        item.codesPostaux.length == 1 ? item.codesPostaux[0] : item.code
                      })`}
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



export default LocationInput;
