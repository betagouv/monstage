import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import $ from 'jquery';
import SchoolPropType from '../prop_types/school';
import { useDebounce } from 'use-debounce';
import Downshift from 'downshift';

const StartAutocompleteAtLength = 2;

export default function AutocompleteSchool({
classes, //PropTypes.string
label, //PropTypes.string.isRequired
required, //PropTypes.bool.isRequired
resourceName, //PropTypes.string.isRequired
selectClassRoom, //PropTypes.bool.isRequired
existingSchool, //PropTypes.objectOf(SchoolPropType)
existingClassRoom, //PropTypes.objectOf(PropTypes.object)
}) {
  const [currentRequest, setCurrentRequest] = useState(null);
  const [requestError, setRequestError] = useState(null);

  const [selectedSchool, setSelectedSchool] = useState(null);
  const [selectedClassRoom, setSelectedClassRoom] = useState(null);

  const [city, setCity] = useState('');
  const [autocompleteCitySuggestions, setAutocompleteCitySuggestions] = useState({});
  const [autocompleteSchoolsSuggestions, setAutocompleteSchoolsSuggestions] = useState([]);
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

  const emitRequest = cityName => {
    setCurrentRequest($.ajax({type: 'POST',
                              url: '/api/schools/search',
                              data: { query: cityName }
                            }).done(fetchDone)
                              .fail(fetchFail))
  };

  const fetchDone = result => {
    debugger
    setAutocompleteCitySuggestions(result.match_by_city);
    setAutocompleteSchoolsSuggestions(result.match_by_name);
    setAutocompleteNoResult(result.no_match);
    setRequestError(null);
    setCurrentRequest(null);
  };

  const fetchFail = (xhr, textStatus) => {
    debugger
    if (textStatus === 'abort') {
      return;
    }
    setRequestError('Une erreur est survenue, veuillez ré-essayer plus tard.');
    setCurrentRequest(null);
    setAutocompleteNoResult(false);
    setAutocompleteCitySuggestions({});
    setAutocompleteSchoolsSuggestions([]);
    setSchoolsInCitySuggestions([]);
    setClassRoomsSuggestions(null);
  };

  const onResetSearch = () => {
    setCity(null);
    setSelectedSchool(null);
    setSelectedClassRoom(null);
    setAutocompleteCitySuggestions({});
    setAutocompleteSchoolsSuggestions([]);
    setSchoolsInCitySuggestions([]);
    setClassRoomsSuggestions(null);
    setAutocompleteNoResult(false);
    setCurrentRequest(null);
  };

  const onSelectCity = (city, schoolsInCitySuggestions) => () => {
    setCity(city)
    setSchoolsInCitySuggestions(schoolsInCitySuggestions)
    setAutocompleteCitySuggestions({})
    setAutocompleteSchoolsSuggestions([])
    setClassRoomsSuggestions(null)
  };

  const onSelectSchool = (event, school) => {
    setSelectedSchool(school);
    setClassRoomsSuggestions(school.class_rooms);
  };

  const onSelectSchoolFromAutocomplete = school => {
    setCity(school.city);
    setSchoolsInCitySuggestions([school]);
    setAutocompleteCitySuggestions({});
    setAutocompleteSchoolsSuggestions([]);
    setSelectedSchool(school);
    setClassRoomsSuggestions(school.class_rooms);
  };

  const renderAutocompleteInput = () => {
    // const {
    //   city,
    //   autocompleteCitySuggestions,
    //   autocompleteSchoolsSuggestions,
    //   currentRequest,
    //   requestError,
    //   autocompleteNoResult,
    // } = this.state;

    // const { resourceName, existingSchool, label, required, classes } = this.props;

    // return (
    //   <div className="form-group custom-label-container">
    //     <div className="input-group">
    //       <input
    //         className={`form-control ${classes || ''} ${autocompleteNoResult ? '' : 'rounded-0'}`}
    //         required={required}
    //         autoComplete="off"
    //         placeholder="Rechercher par ville ou par nom"
    //         type="text"
    //         name={`${resourceName}[school][city]`}
    //         id={`${resourceName}_school_city`}
    //         value={currentCityString()}
    //         onChange={(e) =>{ setCity(event.target.value) }}
    //       />
    //       <label htmlFor={`${resourceName}_school_city`}>
    //         {label}
    //         <abbr title="(obligatoire)" aria-hidden="true">
    //           *
    //         </abbr>
    //       </label>

    //       <div className="input-group-append">
    //         {!currentRequest && (
    //           <button
    //             type="button"
    //             className={`btn btn-outline-secondary btn-clear-city ${
    //               autocompleteNoResult ? '' : 'rounded-0'
    //             }`}
    //             onClick={onResetSearch}
    //           >
    //             <i className="fas fa-times" />
    //           </button>
    //         )}
    //         {currentRequest && (
    //           <button
    //             type="button"
    //             className="btn btn-outline-secondary btn-clear-city"
    //             onClick={onResetSearch}
    //           >
    //             <i className="fas fa-spinner fa-spin" />
    //           </button>
    //         )}
    //       </div>
    //     </div>

    //     <ul className={`${classes || ''} list-group p-0 shadow-sm autocomplete-school-results`}>
    //       <li
    //         className={`list-group-item list-group-item-secondary rounded-0 small py-2 ${
    //           Object.keys(autocompleteCitySuggestions || {}).length > 0 ? '' : 'd-none'
    //         }`}
    //       >
    //         Ville(s)
    //       </li>
    //       {Object.keys(autocompleteCitySuggestions || {}).map(currentCity => (
    //         <li
    //           type="button"
    //           className="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
    //           key={currentCity}
    //           onClick={onSelectCity(currentCity, autocompleteCitySuggestions[currentCity])}
    //         >
    //           <span dangerouslySetInnerHTML={{ __html: currentCity }} />
    //           <span className="badge-secondary badge-pill small">
    //             {autocompleteCitySuggestions[currentCity].length} établissement
    //             {autocompleteCitySuggestions[currentCity].length > 1 ? 's' : ''}
    //           </span>
    //         </li>
    //       ))}

    //       <li
    //         className={`list-group-item  list-group-item-secondary small py-2 ${
    //           (autocompleteSchoolsSuggestions || []).length > 0 ? '' : 'd-none'
    //         }`}
    //       >
    //         Etablissement(s)
    //       </li>
    //       {(autocompleteSchoolsSuggestions || []).map(currentSchool => (
    //         <li
    //           type="button"
    //           className="list-group-item list-group-item-action text-left"
    //           key={currentSchool.id}
    //           onClick={event => onSelectSchoolFromAutocomplete(currentSchool)}
    //         >
    //           <span dangerouslySetInnerHTML={{ __html: currentSchool.pg_search_highlight_name }} />
    //           <br />
    //           <small>
    //             {currentSchool.city} – {currentSchool.zipcode}
    //           </small>
    //         </li>
    //       ))}
    //       {requestError && (
    //         <li className="list-group-item list-group-item-danger small">{requestError}</li>
    //       )}
    //       {autocompleteNoResult && (
    //         <li className="list-group-item list-group-item-info small">
    //           Aucun résultat pour votre recherche. Assurez-vous que l’établissement renseigné est un
    //           établissement REP ou REP+.
    //         </li>
    //       )}
    //     </ul>
    //   </div>
    // );
    return (
      <Downshift
          initialInputValue={city}
          onChange={setCity}
          selectedItem={city}
          itemToString={(item) => { (item && item.properties) ? item.properties.label : ''} }
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
            <div>
              <label {...getLabelProps({className: "label",
                                        htmlFor: `${resourceName}_school_city` })}>
                 {label}
                 <abbr title="(obligatoire)" aria-hidden="true">
                   *
                 </abbr>
               </label>

              <div>
                <input
                  required={required}

                  {...getInputProps({
                    onChange: (e) => { setCity(event.target.value) },
                    value: currentCityString(),
                    className: `form-control ${classes || ''} ${autocompleteNoResult ? '' : 'rounded-0'}`,
                    name: `${resourceName}[school][city]`,
                    id: `${resourceName}_school_city`,
                    placeholder: 'Adresse',
                  })}
                />
              </div>
              <div>
                <div className="search-in-place bg-white shadow">
                  <ul
                    {...getMenuProps({
                      className: `${classes || ''} list-group p-0 shadow-sm autocomplete-school-results`,
                    })}
                  >
                    {isOpen
                      ? (
                          <>
                            <li
                              className={`list-group-item list-group-item-secondary rounded-0 small py-2 ${
                                Object.keys(autocompleteCitySuggestions || {}).length > 0 ? '' : 'd-none'
                              }`}
                            >
                              Ville(s)
                            </li>
                            {Object.keys(autocompleteCitySuggestions || {}).map(currentCity => (
                              <li
                                type="button"
                                className="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                                key={currentCity}
                                onClick={onSelectCity(currentCity, autocompleteCitySuggestions[currentCity])}
                              >
                                <span dangerouslySetInnerHTML={{ __html: currentCity }} />
                                <span className="badge-secondary badge-pill small">
                                  {autocompleteCitySuggestions[currentCity].length} établissement
                                  {autocompleteCitySuggestions[currentCity].length > 1 ? 's' : ''}
                                </span>
                              </li>
                            ))}
                            <li
                              className={`list-group-item  list-group-item-secondary small py-2 ${
                                (autocompleteSchoolsSuggestions || []).length > 0 ? '' : 'd-none'
                              }`}
                            >
                              Etablissement(s)
                            </li>
                            {(autocompleteSchoolsSuggestions || []).map(currentSchool => (
                              <li
                                type="button"
                                className="list-group-item list-group-item-action text-left"
                                key={currentSchool.id}
                                onClick={event => onSelectSchoolFromAutocomplete(currentSchool)}
                              >
                                <span dangerouslySetInnerHTML={{ __html: currentSchool.pg_search_highlight_name }} />
                                <br />
                                <small>
                                  {currentSchool.city} – {currentSchool.zipcode}
                                </small>
                              </li>
                            ))}
                          </>
                        )
                      : null}
                      {requestError && (
                        <li className="list-group-item list-group-item-danger small">{requestError}</li>
                      )}
                      {autocompleteNoResult && (
                        <li className="list-group-item list-group-item-info small">
                          Aucun résultat pour votre recherche. Assurez-vous que l’établissement renseigné est un
                          établissement REP ou REP+.
                        </li>
                      )}
                  </ul>
                </div>
              </div>
            </div>
          )}
        </Downshift>
      )
  };

  const renderSchoolsInput = () => {
    // const { selectedSchool, schoolsInCitySuggestions } = this.state;
    // const { resourceName, existingSchool, classes } = this.props;

    const isWaitingCitySelection =
      schoolsInCitySuggestions.length === 0 && !selectedSchool && !existingSchool;
    const isAlreadySelected = schoolsInCitySuggestions.length === 0 && existingSchool;
    const hasPendingSuggestion = schoolsInCitySuggestions.length > 0;

    return (
      <div className={`form-group ${isWaitingCitySelection ? 'opacity-05' : ''}`}>
        {isWaitingCitySelection && (
          <div className="custom-label-container">
            <input
              value=""
              disabled
              className={`form-control ${classes || ''}`}
              type="text"
              id={`${resourceName}_school_name`}
            />
            <label htmlFor={`${resourceName}_school_name`}>
              Collège
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
          </div>
        )}
        {isAlreadySelected && (
          <div class="custom-label-container">
            <input
              readOnly
              disabled
              className={`form-control ${classes || ''}`}
              type="text"
              value={existingSchool.name}
              name={`${resourceName}[school_name]`}
              id={`${resourceName}_school_name`}
            />
            <label htmlFor={`${resourceName}_school_name`}>
              Collège
              <abbr title="(obligatoire)" aria-hidden="true">
                *
              </abbr>
            </label>
            <input type="hidden" value={existingSchool.id} name={`${resourceName}[school_id]`} />
          </div>
        )}
        {hasPendingSuggestion && (
          <div>
            {(schoolsInCitySuggestions || []).map(school => (
              <div className="custom-control custom-radio" key={`school-${school.id}`}>
                <input
                  type="radio"
                  id={`select-school-${school.id}`}
                  name={`${resourceName}[school_id]`}
                  value={school.id}
                  checked={selectedSchool && selectedSchool.id == school.id}
                  onChange={event => onSelectSchool(event, school)}
                  required
                  className="custom-control-input"
                />
                <label htmlFor={`select-school-${school.id}`} className="custom-control-label">
                  {school.name}
                </label>
              </div>
            ))}
          </div>
        )}
      </div>
    );
  };

  const renderClassRoomsInput = () => {
    // const { selectedClassRoom, classRoomsSuggestions } = this.state;
    // const { resourceName, existingClassRoom, classes } = this.props;

    const isWaitingSchoolSelection =
      classRoomsSuggestions === null && !selectedClassRoom && !existingClassRoom;
    const isAlreadySelected = classRoomsSuggestions === null && existingClassRoom;
    const hasPendingSuggestion = classRoomsSuggestions && classRoomsSuggestions.length > 0;

    return (
      <div className={`form-group custom-label-container ${isWaitingSchoolSelection ? 'opacity-05' : ''}`}>

        {isWaitingSchoolSelection && (
          <>
            <input
              value=""
              disabled
              className={`form-control ${classes || ''}`}
              type="text"
              id={`${resourceName}_class_room_id`}
            />
            <label htmlFor={`${resourceName}_class_room_id`}>Classe</label>
          </>
        )}

        {isAlreadySelected && (
          <>
            <input
              disabled
              readOnly
              className={`form-control ${classes || ''}`}
              type="text"
              value={existingClassRoom.name}
              name={`${resourceName}[class_room_name]`}
              id={`${resourceName}_class_room_name`}
            />
            <label htmlFor={`${resourceName}_class_room_id`}>Classe</label>
            <input
              value={existingClassRoom.id}
              type="hidden"
              name={`${resourceName}[class_room_id]`}
            />
          </>
        )}

        {hasPendingSuggestion && (
          <>
            <select
              className="form-control"
              name={`${resourceName}[class_room_id]`}
              id={`${resourceName}_class_room_id`}
            >
              {!selectedClassRoom && (
                <option key="class-room-null" selected disabled>
                  -- Veuillez choisir une classe --
                </option>
              )}
              {(classRoomsSuggestions || []).map(classRoom => (
                <option
                  key={`class-room-${classRoom.id}`}
                  value={classRoom.id}
                  selected={selectedClassRoom && selectedClassRoom.id === classRoom.id}
                >
                  {classRoom.name}
                </option>
              ))}
            </select>
            <label htmlFor={`${resourceName}_class_room_id`}>Classe</label>
          </>
        )}
        {classRoomsSuggestions && classRoomsSuggestions.length === 0 && (
          <>
            <input
              placeholder="Aucune classe disponible"
              readOnly
              name={`${resourceName}[class_room_id]`}
              id={`${resourceName}_class_room_id`}
              value=""
              className={`form-control ${classes || ''}`}
              type="text"
            />
            <label htmlFor={`${resourceName}_class_room_id`}>Classe</label>
          </>
        )}
      </div>
    );
  };


  useEffect(() => {
    if (city.length > StartAutocompleteAtLength) {
      emitRequest(city);
    } else {
      setAutocompleteCitySuggestions({})
    }
  }, [city]);

  return (
    <div className="autocomplete-school-container">
      {renderAutocompleteInput()}
      {city !== null && (
        <>
          {renderSchoolsInput()}
          {selectClassRoom && renderClassRoomsInput()}
        </>
      )}
    </div>
  );
}

