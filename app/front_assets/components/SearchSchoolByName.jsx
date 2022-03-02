import React, { useEffect, useState } from 'react';
import $ from 'jquery';
import Downshift from 'downshift';
import { visitURLWithOneParam, getParamValueFromUrl, clearSearch } from '../utils/urls';
import { endpoints } from '../utils/api';

const StartAutocompleteAtLength = 2;

export default function SearchSchool({
  classes, // PropTypes.string
  label, // PropTypes.string.isRequired
  required, // PropTypes.bool.isRequired
  resourceName, // PropTypes.string.isRequired
  chosenSchoolName,
}) {
  const [currentRequest, setCurrentRequest] = useState(null);
  const [requestError, setRequestError] = useState(null);

  const [city, setCity] = useState('');
  const [autocompleteSchoolsSuggestions, setSearchSchoolsSuggestions] = useState([]);
  const [autocompleteNoResult, setAutocompleteNoResult] = useState(false);
  const cityCurrentlyChosen = getParamValueFromUrl('school_id') || false;

  const currentCityString = () => {
    if (city === null || city === undefined) {
      return '';
    }
    return city.replace(/<b>/g, '').replace(/<\/b>/g, '');
  };

  const emitRequest = (cityName) => {
    setCurrentRequest(
      $.ajax({ type: 'POST', url: endpoints['apiSearchSchool'](), data: { query: cityName } })
        .done(fetchDone)
        .fail(fetchFail),
    );
  };

  const fetchDone = (result) => {
    setSearchSchoolsSuggestions(result.match_by_name);
    setAutocompleteNoResult(result.no_match);
    setRequestError(null);
    setCurrentRequest(null);
  };

  const fetchFail = (_xhr, textStatus) => {
    if (textStatus === 'abort') {
      return;
    }
    setRequestError('Une erreur est survenue, veuillez ré-essayer plus tard.');
    setCurrentRequest(null);
    setAutocompleteNoResult(false);
    setSearchSchoolsSuggestions([]);
  };

  const onResetSearch = () => {
    setCity(null);
    setSearchSchoolsSuggestions([]);
    setAutocompleteNoResult(false);
    setCurrentRequest(null);
    clearSearch();
  };

  // search is done by city only
  // see: https://github.com/downshift-js/downshift#onchange
  const onDownshiftChange = (selectedItem) => {
    setCity(selectedItem.city);
    visitURLWithOneParam('school_id', selectedItem.id);
  };

  const inputChange = (event) => {
    setCity(event.target.value);
  }

  const inputFocus = () => {
    if (cityCurrentlyChosen) { onResetSearch() }
  }

  const renderAutocompleteInput = () => {
    return (
      <Downshift
        initialInputValue={city}
        onChange={onDownshiftChange}
        selectedItem={city}
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
          <div className="name-search form-group custom-label-container">
            <div className="input-group">
              <input
                {...getInputProps({
                  onChange: inputChange,
                  onFocus: inputFocus,
                  value: currentCityString(),
                  className: `smashed form-control form-control-lg ${classes || ''} ${autocompleteNoResult ? 'rounded-0' : ''}`,
                  id: `${resourceName}_school_name`,
                  name: `${resourceName}[school][name]`,
                  required: required,
                })}
              />
              <label
                {...getLabelProps({ className: cityCurrentlyChosen ? 'chosen-name' : 'not-chosen-name', htmlFor: `${resourceName}_school_city` })}
              >
                {cityCurrentlyChosen ? chosenSchoolName : label}
              </label>
              <div className="input-group-append">
                {!currentRequest && (
                  <button
                    type="button"
                    className={`fr-btn btn-clear-city  ${cityCurrentlyChosen ? 'text-danger' : 'text-primary'}`}
                    onClick={onResetSearch}
                    aria-label="Réinitialiser la recherche"
                  >
                    <i className={cityCurrentlyChosen ? 'fas fa-times ' : 'fas fa-search '} />
                  </button>
                )}
                {currentRequest && (
                  <button
                    type="button"
                    className=" fr-btn fr-btn--secondary btn-clear-city"
                    onClick={onResetSearch}
                    aria-label="Réinitialiser la recherche"
                  >
                    <i className="fas fa-spinner fa-spin" />
                  </button>
                )}
              </div>
            </div>
            <div className="search-in-place bg-white shadow">
              <ul
                {...getMenuProps({
                  className: `${classes || ''
                    } list-group p-0 shadow-sm autocomplete-school-results`,
                })}
              >
                {isOpen ? (
                  <>
                    <li
                      className={`list-group-item list-group-item-secondary small py-2 ${(autocompleteSchoolsSuggestions || []).length > 0 ? '' : 'd-none'
                        }`}
                    >
                      Etablissement(s)
                    </li>
                    {
                      (autocompleteSchoolsSuggestions || []).reduce(
                        (accumulator, currentSchool) => {
                          const index = accumulator.itemIndex++;

                          accumulator.result.push(
                            <li
                              {...getItemProps({
                                index,
                                item: currentSchool,
                                className: `list-group-item list-group-item-action text-left listview-item ${highlightedIndex === index ? 'highlighted-listview-item' : ''
                                  }`,
                                key: `school-${currentSchool.id}`,
                              })}
                            >
                              <span
                                dangerouslySetInnerHTML={{
                                  __html: currentSchool.pg_search_highlight_name || currentSchool.name,
                                }}
                              />
                              <br />
                              <small>
                                {currentSchool.city} – {currentSchool.zipcode}
                              </small>
                            </li>,
                          );
                          return accumulator;
                        },
                        {
                          result: [],
                          itemIndex: 0,
                        },
                      ).result
                    }
                  </>
                ) : null}
                {requestError && (
                  <li className="list-group-item list-group-item-danger small">{requestError}</li>
                )}
                {autocompleteNoResult && (
                  <li className="list-group-item list-group-item-info small">
                    Aucun résultat pour votre recherche. Assurez-vous que l’établissement renseigné
                    est un établissement REP ou REP+.
                  </li>
                )}
              </ul>
            </div>
          </div>
        )}
      </Downshift>
    );
  };

  useEffect(() => {
    if (city && city.length > StartAutocompleteAtLength) {
      emitRequest(city);
    }
  }, [city]);

  return (
    <div className="autocomplete-school-container">
      {renderAutocompleteInput()}
    </div>
  );
}
