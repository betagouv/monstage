import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import $ from 'jquery';
import { useDebounce } from 'use-debounce';
import Downshift from 'downshift';
import SchoolPropType from '../prop_types/school';
import SchoolSelectInput from './search_school/SchoolSelectInput';
import ClassRoomInput from './search_school/ClassRoomInput';
import { endpoints } from '../utils/api';

const StartAutocompleteAtLength = 2;

export default function SearchSchool({
  classes, // PropTypes.string
  label, // PropTypes.string.isRequired
  required, // PropTypes.bool.isRequired
  resourceName, // PropTypes.string.isRequired
  selectClassRoom, // PropTypes.bool.isRequired
  existingSchool, // PropTypes.objectOf(SchoolPropType)
  existingClassRoom, // PropTypes.objectOf(PropTypes.object)
}) {
  const [currentRequest, setCurrentRequest] = useState(null);
  const [requestError, setRequestError] = useState(null);

  const [selectedSchool, setSelectedSchool] = useState(null);
  const [selectedClassRoom, setSelectedClassRoom] = useState(null);

  const [city, setCity] = useState('');
  const [chosenCity, setChosenCity] = useState('');
  const [autocompleteCitySuggestions, setAutocompleteCitySuggestions] = useState({});
  const [autocompleteSchoolsSuggestions, setSearchSchoolsSuggestions] = useState([]);
  const [autocompleteNoResult, setAutocompleteNoResult] = useState(false);

  const [schoolsInCitySuggestions, setSchoolsInCitySuggestions] = useState([]);
  const [classRoomsSuggestions, setClassRoomsSuggestions] = useState(null);

  const currentCityString = () => {
    if (city === null || city === undefined) {
      return '';
    }
    return city.length === 0 && existingSchool
      ? existingSchool.city
      : city.replace(/<b>/g, '').replace(/<\/b>/g, '');
  };

  const emitRequest = (cityName) => {
    setCurrentRequest(
      $.ajax({ type: 'POST', url: endpoints['apiSearchSchool'](), data: { query: cityName } })
        .done(fetchDone)
        .fail(fetchFail),
    );
  };

  const fetchDone = (result) => {
    setAutocompleteCitySuggestions(result.match_by_city);
    setSearchSchoolsSuggestions(result.match_by_name);
    const withNoMatch = isEmpty(result.match_by_name) && isEmpty(result.match_by_city)
    setAutocompleteNoResult((chosenCity === '') && withNoMatch);
    setRequestError(null);
    setCurrentRequest(null);
  };

  const isEmpty = (object) => { return Object.keys(object).length === 0; }

  const fetchFail = (xhr, textStatus) => {
    if (textStatus === 'abort') {
      return;
    }
    setRequestError('Une erreur est survenue, veuillez ré-essayer plus tard.');
    setCurrentRequest(null);
    setAutocompleteNoResult(false);
    setAutocompleteCitySuggestions({});
    setSearchSchoolsSuggestions([]);
    setSchoolsInCitySuggestions([]);
    setClassRoomsSuggestions(null);
  };

  const onResetSearch = () => {
    setCity(null);
    setChosenCity('');
    setSelectedSchool(null);
    setSelectedClassRoom(null);
    setAutocompleteCitySuggestions({});
    setSearchSchoolsSuggestions([]);
    setSchoolsInCitySuggestions([]);
    setClassRoomsSuggestions(null);
    setAutocompleteNoResult(false);
    setCurrentRequest(null);
  };

  // search is done by city or school
  // either we find city
  // either we find school
  // based on selection (string:city, object:school)
  // see: https://github.com/downshift-js/downshift#onchange
  const onDownshiftChange = (selectedItem) => {
    if (autocompleteCitySuggestions.hasOwnProperty(selectedItem)) {
      setCity(selectedItem);
      setSchoolsInCitySuggestions(autocompleteCitySuggestions[selectedItem]);
      setClassRoomsSuggestions(null);
    } else {
      setCity(selectedItem.city);
      setSchoolsInCitySuggestions([selectedItem]);
      setSelectedSchool(selectedItem);
      setClassRoomsSuggestions(selectedItem.class_rooms);
    }
    setChosenCity(selectedItem);
    setAutocompleteCitySuggestions({});
    setSearchSchoolsSuggestions([]);
  };

  const inputChange = (event) => {
    setCity(event.target.value);
    if (event.target.value === '') { onResetSearch()}
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
            <label
              {...getLabelProps({ className: 'fr-label', htmlFor: `${resourceName}_school_city` })}
            >
              {label}
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
            <div className="input-group-append">
              <input
                {...getInputProps({
                  onChange: inputChange,
                  value: currentCityString(),
                  className: `fr-input ${classes || ''} ${
                    autocompleteNoResult ? '' : 'rounded-0'
                  }`,
                  id: `${resourceName}_school_city`,
                  placeholder: 'Adresse',
                  name: `${resourceName}[school][city]`,
                  required: required,
                })}
              />
                {!currentRequest && (
                  <button
                    type="button"
                    className={`fr-btn fr-btn--secondary btn-clear-city ml-1 ${
                      autocompleteNoResult ? '' : 'rounded-0'
                    }`}
                    onClick={onResetSearch}
                    aria-label="Réinitialiser la recherche"
                  >
                    <span className="fr-icon-arrow-go-back-fill fr-icon--sm" aria-hidden="true"></span>
                  </button>
                )}
                {currentRequest && (
                  <button
                    type="button"
                    className="fr-btn fr-btn--secondary btn-clear-city"
                    onClick={onResetSearch}
                    aria-label="Réinitialiser la recherche"
                  >
                  <span className="fr-icon-close-line"></span>
                  </button>
                )}

            </div>

            <div className="search-in-place bg-white shadow">
              <ul
                {...getMenuProps({
                  className: `${
                    classes || ''
                  } list-group p-0 shadow-sm autocomplete-school-results`,
                })}
              >
                {isOpen ? (
                  <>
                    <li
                      className={`list-group-item list-group-item-secondary rounded-0 small py-2 ${
                        Object.keys(autocompleteCitySuggestions || {}).length > 0 ? '' : 'd-none'
                      }`}
                    >
                      Ville(s)
                    </li>
                    {Object.keys(autocompleteCitySuggestions || {}).map((currentCity, index) => (
                      <li
                        {...getItemProps({
                          index,
                          item: currentCity,
                          className: `list-group-item list-group-item-action d-flex justify-content-between align-items-center listview-item ${
                            highlightedIndex === index ? 'highlighted-listview-item' : ''
                          }`,
                          key: `city-${currentCity}`,
                        })}
                      >
                        <span  className="fr-mx-1w" dangerouslySetInnerHTML={{ __html: currentCity }} />
                        <span className="fr-badge fr-badge--sm fr-badge--success fr-badge--no-icon fr-ml-1w">
                          {autocompleteCitySuggestions[currentCity].length} établissement
                          {autocompleteCitySuggestions[currentCity].length > 1 ? 's' : ''}
                        </span>
                      </li>
                    ))}
                    <li
                      className={`list-group-item list-group-item-secondary small py-2 ${
                        (autocompleteSchoolsSuggestions || []).length > 0 ? '' : 'd-none'
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
                                className: `list-group-item list-group-item-action text-left listview-item ${
                                  highlightedIndex === index ? 'highlighted-listview-item' : ''
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
                          itemIndex: Object.keys(autocompleteCitySuggestions || {}).length,
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
    } else {
      setAutocompleteCitySuggestions({});
    }
  }, [city]);

  return (
    <div className="autocomplete-school-container">
      {renderAutocompleteInput()}
      {city !== null && (
        <>
          {
            <SchoolSelectInput
              setClassRoomsSuggestions={setClassRoomsSuggestions}
              selectedSchool={selectedSchool}
              setSelectedSchool={setSelectedSchool}
              schoolsInCitySuggestions={schoolsInCitySuggestions}
              resourceName={resourceName}
              existingSchool={existingSchool}
              classes={classes}
            />
          }
          {selectClassRoom && (
            <ClassRoomInput
              selectedClassRoom={selectedClassRoom}
              classRoomsSuggestions={classRoomsSuggestions}
              resourceName={resourceName}
              existingClassRoom={existingClassRoom}
              classes={classes}
            />
          )}
        </>
      )}
    </div>
  );
}
