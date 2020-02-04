import React, { useEffect, useState } from 'react';
import Turbolinks from 'turbolinks';
import $ from 'jquery';
import Downshift from 'downshift';

const MAX_RADIUS = 60000;
const MIN_RADIUS = 1000;
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

function SearchInternshipOffer({ url, currentCitySearch, currentRadius }) {
  const [currentSearch, setCurrentSearch] = useState(currentCitySearch || '');
  const [currentSelectedItem, setCurrentSelectedItem] = useState(null);
  const [searchResults, setSearchResults] = useState([]);
  const [radius, setRadius] = useState(currentRadius || MAX_RADIUS);

  const fetchDone = result => {
    setSearchResults(result);
  };

  const inputChange = event => {
    setCurrentSearch(event.target.value);
  };

  const onRadiusChange = event => {
    setRadius(event.target.value);
  };

  const filterOfferByLocation = event => {
    const searchParams = new URLSearchParams(window.location.search);

    if (currentSelectedItem) {
      searchParams.set('city', currentSelectedItem.nom);
      searchParams.set('latitude', currentSelectedItem.centre.coordinates[1]);
      searchParams.set('longitude', currentSelectedItem.centre.coordinates[0]);
      searchParams.set('radius', radius);
    } else {
      searchParams.delete('radius');
      searchParams.delete('city');
      searchParams.delete('latitude');
      searchParams.delete('longitude');
    }
    searchParams.delete('page');

    Turbolinks.visit(`${url}?${searchParams.toString()}`);
    if (event) {
      event.preventDefault();
    }
  };

  const resetSelectedResult = () => {
    setCurrentSearch('');
    setRadius(60);
    filterOfferByLocation({});
  };

  const doRequest = () => {
    $.ajax({
      type: 'GET',
      url: 'https://geo.api.gouv.fr/communes',
      data: {
        nom: currentSearch,
        fields: ['nom', 'centre', 'departement', 'codesPostaux'].join(','),
        limit: 10,
        boost: 'population',
      },
    }).done(fetchDone);
  };

  useEffect(() => {
    if (currentSearch && currentSearch != currentCitySearch && currentSearch.length > 0) {
      doRequest(currentSearch);
    }
  }, [currentSearch]);

  return (
    <Downshift initialInputValue={currentCitySearch} onChange={setCurrentSelectedItem} itemToString={item => (item ? item.nom : '')}>
      {({
        getInputProps,
        getItemProps,
        getLabelProps,
        getMenuProps,
        isOpen,
        inputValue,
        selectedItem,
      }) => (
        <form data-turbolink={false} onSubmit={filterOfferByLocation}>
          <div className="form-row align-items-center">
            <div className="col-auto">
              <label {...getLabelProps()} className="p-0 m-0" htmlFor="input-search-by-city">
                <strong>Autour de</strong>
              </label>
            </div>
            <div className="col-auto">
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
                  <button
                    type="button"
                    className="btn btn-outline-secondary btn-clear-city"
                    onClick={resetSelectedResult}
                  >
                    <i className="fas fa-times" />
                  </button>
                </div>
                <div className={`search-in-place bg-white shadow ${!isOpen && !selectedItem ? 'd-none' : 'pt-3'}`}>
                  <ul
                    {...getMenuProps({
                      className: 'p-0 m-0',
                    })}
                  >
                    {isOpen
                      ? searchResults.map((item, index) => (
                          <li
                            {...getItemProps({
                              className: 'py-2 px-3 listview-item',
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
                  {selectedItem && (
                    <>
                      <div class="px-3 mb-3">
                        <div className="p-2 badge badge-light rounded-lg">
                          {selectedItem.nom}
                          <a class="mx-1 badge-clear rounded" href={url}>
                            <i class="fas fa-times" />
                          </a>
                        </div>
                      </div>

                      <div className="px-3 form-group">
                        <label className='mb-0 font-weight-bold' htmlFor="radius">
                          Dans un rayon de
                        </label>

                        <div className="slider-legend small">
                          <div
                            className="slider-handle text-center"
                            style={{ left: `${radiusPercentage(radius)}%` }}
                          >
                            <span className="mr-1">{radiusInKm(radius)}km</span>
                            <span key={radius}>
                              <i className={`fas ${iconForRadius(radius)}`} />
                            </span>
                          </div>
                        </div>

                        <input
                          type="range"
                          min={MIN_RADIUS}
                          max={MAX_RADIUS}
                          id="radius"
                          name="radius"
                          className="form-control-range"
                          value={radius}
                          onChange={onRadiusChange}
                        />
                      </div>

                      <div className="p-3 footer-autocomplete">
                        <button type="submit" className="float-right btn btn-warning btn-sm">
                          Appliquer
                        </button>
                        <a href={url} className="float-left btn btn-link btn-sm">
                          Effacer
                        </a>
                        <div class="clearfix" />
                      </div>
                    </>
                  )}
                </div>
              </div>
            </div>
          </div>
        </form>
      )}
    </Downshift>
  );
}
export default SearchInternshipOffer;
