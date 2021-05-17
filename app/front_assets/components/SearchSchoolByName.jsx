import React, { useEffect, useState } from 'react';
import $ from 'jquery';
import Downshift from 'downshift';
import { visitURLWithParam, getParamValueFromUrl } from '../utils/urls'

const StartAutocompleteAtLength = 2;

export default function SearchSchool({
  classes, // PropTypes.string
  label, // PropTypes.string.isRequired
  required, // PropTypes.bool.isRequired
  resourceName, // PropTypes.string.isRequired
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
      $.ajax({ type: 'POST', url: '/api/schools/search', data: { query: cityName } })
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
    visitURLWithParam('school_id', '');
  };

  // search is done by city only
  // see: https://github.com/downshift-js/downshift#onchange
  const onDownshiftChange = (selectedItem) => {
    setCity(selectedItem.city);
    visitURLWithParam('school_id', selectedItem.id);
    setSearchSchoolsSuggestions([]);
  };

  const inputChange = (event) => {
    setCity(event.target.value);
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
          <div className="form-group custom-label-container">
            <div className="input-group">
              <input
                {...getInputProps({
                  onChange: inputChange,
                  value: currentCityString(),
                  className: `form-control ${classes || ''} ${autocompleteNoResult ? '' : 'rounded-0'
                    }`,
                  id: `${resourceName}_school_city`,
                  placeholder: 'Adresse',
                  name: `${resourceName}[school][city]`,
                  required: required,
                })}
              />
              <label
                {...getLabelProps({ className: 'text-muted', htmlFor: `${resourceName}_school_city` })}
              >
                {label}
              </label>
              <div className="input-group-append">
                {!currentRequest && (
                  <button
                    type="button"
                    className={`btn btn-outline-secondary btn-clear-city ${autocompleteNoResult ? '' : 'rounded-0'} ${cityCurrentlyChosen ? 'text-danger' : ''}`}
                    onClick={onResetSearch}
                    aria-label="Réinitialiser la recherche"
                  >
                    <i className="fas fa-times" />
                  </button>
                )}
                {currentRequest && (
                  <button
                    type="button"
                    className="btn btn-outline-secondary btn-clear-city"
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
