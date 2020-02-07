import React, { useEffect, useState } from 'react';
import Turbolinks from 'turbolinks';
import Downshift from 'downshift';
import $ from 'jquery';

const MAX_RADIUS = 60000;
const MIN_RADIUS = 5000;
const KILO_METER = 1000;

function radiusPercentage(radius) {
  return Math.ceil((radius * 100) / MAX_RADIUS);
}
function radiusInKm(radius) {
  return Math.ceil(radius / KILO_METER);
}

function iconForRadius(radius) {
  const comparableRadius = radiusInKm(radius);

  if (comparableRadius < 10) {
    return 'fa-walking';
  }
  if (comparableRadius < 20) {
    return 'fa-bus';
  }
  return 'fa-train';
}

function SearchInternshipOffer({ url, currentCitySearch, initialRadius }) {
  const [searchTerm, setSearchTerm] = useState(null);
  const [downshiftSelectedItem, setDownshiftSelectedItem] = useState(null);
  const [radius, setRadius] = useState(initialRadius);
  const [searchResults, setSearchResults] = useState([]);

  const fetchDone = result => {
    setSearchResults(result);
  };

  const inputChange = event => {
    setSearchTerm(event.target.value);
  };

  const onRadiusChange = event => {
    setRadius(parseInt(event.target.value), 10);
  };
  const filterOfferByLocation = event => {
    const searchParams = new URLSearchParams(window.location.search);

    if (downshiftSelectedItem) {
      searchParams.set('city', downshiftSelectedItem.nom);
      searchParams.set('latitude', downshiftSelectedItem.centre.coordinates[1]);
      searchParams.set('longitude', downshiftSelectedItem.centre.coordinates[0]);
    }
    if (radius) {
      searchParams.set('radius', radius);
    }
    searchParams.delete('page');

    Turbolinks.visit(`${url}?${searchParams.toString()}`);

    if (event) {
      event.preventDefault();
    }
  };

  const searchCityByName = () => {
    $.ajax({
      type: 'GET',
      url: 'https://geo.api.gouv.fr/communes',
      data: {
        nom: searchTerm,
        fields: ['nom', 'centre', 'departement', 'codesPostaux'].join(','),
        limit: 10,
        boost: 'population',
      },
    }).done(fetchDone);
  };

  useEffect(() => {
    if (searchTerm && searchTerm.length > 0 && searchTerm != currentCitySearch) {
      searchCityByName(searchTerm);
    }
  }, [searchTerm]);

  return (
    <Downshift
      initialInputValue={currentCitySearch || ''}
      onChange={setDownshiftSelectedItem}
      itemToString={item => (item ? item.nom : '')}
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
      }) => (
        <form data-turbolink={false} onSubmit={filterOfferByLocation}>
          <div className="form-row align-items-center">
            <div className="col-auto mr-0 mr-sm-3">
              <div className="form-group">
                <label {...getLabelProps()} className="p-0" htmlFor="input-search-by-city">
                  <strong>Autour de</strong>
                </label>
                <div className="input-group">
                  <div className="input-group-prepend">
                    <span className="input-group-text">
                      <i className="fas fa-map-marker-alt" />
                    </span>
                  </div>
                  <input
                    {...getInputProps({
                      onChange: inputChange,
                      value: inputValue,
                      className: 'form-control',
                    })}
                  />
                  <div className="input-group-append">
                    <a
                      href={url}
                      title="Effacer les options de recherche"
                      className="btn btn-outline-secondary btn-clear-city"
                    >
                      <i className="fas fa-times" />
                    </a>
                  </div>
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
              </div>
            </div>
            <div className="col-auto mr-0 mr-sm-3">
              <div className="form-group">
                <label className="font-weight-bold" htmlFor="radius">
                  Dans un rayon de
                </label>
                <input
                  type="range"
                  min={MIN_RADIUS}
                  max={MAX_RADIUS}
                  id="radius"
                  name="radius"
                  className="form-control-range form-control"
                  value={radius}
                  onChange={onRadiusChange}
                  step={5000}
                />
                <div className="slider-legend small">
                  <div
                    className="slider-handle text-center"
                    style={{ left: `${radiusPercentage(radius)}%` }}
                  >
                    <span className="mr-1">{radiusInKm(radius)} km</span>
                    <span key={radius}>
                      <i className={`fas ${iconForRadius(radius)}`} />
                    </span>
                  </div>
                </div>
              </div>
            </div>
            <div className="col ml-0 ml-sm-3">
              <div className="form-group mt-2 mb-0">
                <button
                  type="submit"
                  className="btn btn-outline-dark btn-xs-sm float-right float-sm-none px-3"
                >
                  <i className="fas fa-search" />
                  <span className="ml-1 d-none d-sm-inline">Rechercher</span>
                </button>
              </div>
            </div>
          </div>
        </form>
      )}
    </Downshift>
  );
}
export default SearchInternshipOffer;
