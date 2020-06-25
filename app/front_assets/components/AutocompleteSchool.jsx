import React from 'react';
import PropTypes from 'prop-types';
import $ from 'jquery';
import SchoolPropType from '../prop_types/school';

const StartAutocompleteAtLength = 2;

class AutocompleteSchool extends React.Component {
  static propTypes = {
    classes: PropTypes.string,
    label: PropTypes.string.isRequired,
    required: PropTypes.bool.isRequired,
    resourceName: PropTypes.string.isRequired,
    selectClassRoom: PropTypes.bool.isRequired,
    existingSchool: PropTypes.objectOf(SchoolPropType),
    existingClassRoom: PropTypes.objectOf(PropTypes.object),
  };

  static defaultProps = {
    classes: null,
    existingSchool: null,
    existingClassRoom: null,
  };

  state = {
    currentRequest: null,
    requestError: null,

    selectedSchool: null,
    selectedClassRoom: null,

    city: '',
    autocompleteCitySuggestions: {},
    autocompleteSchoolsSuggestions: [],
    autocompleteNoResult: false,

    schoolsInCitySuggestions: [],
    classRoomsSuggestions: null,
  };

  constructor(props) {
    super(props);
    this.emitRequest = this.emitRequest.bind(this);
    this.fetchDone = this.fetchDone.bind(this);
    this.fetchFail = this.fetchFail.bind(this);
  }

  fetchData = cityName => {
    const { currentRequest } = this.state;

    if (currentRequest) {
      this.setState({ currentRequest: null }, () => {
        currentRequest.abort();
        this.emitRequest(cityName);
      });
    } else {
      this.emitRequest(cityName);
    }
  };

  currentCityString = () => {
    const { city } = this.state;
    const { existingSchool } = this.props;

    if (city === null || city === undefined) {
      return '';
    }
    return city.length === 0 && existingSchool
      ? existingSchool.city
      : city.replace(/<b>/g, '').replace(/<\/b>/g, '');
  };

  emitRequest = cityName => {
    this.setState({
      currentRequest: $.ajax({
        type: 'POST',
        url: '/api/schools/search',
        data: { query: cityName },
      })
        .done(this.fetchDone)
        .fail(this.fetchFail),
    });
  };

  fetchDone = result => {
    this.setState({
      autocompleteCitySuggestions: result.match_by_city,
      autocompleteSchoolsSuggestions: result.match_by_name,
      autocompleteNoResult: result.no_match,
      requestError: null,
      currentRequest: null,
    });
  };

  fetchFail = (xhr, textStatus) => {
    if (textStatus === 'abort') {
      return;
    }
    this.setState({
      requestError: 'Une erreur est survenue, veuillez ré-essayer plus tard.',
      currentRequest: null,
      autocompleteNoResult: false,
      autocompleteCitySuggestions: {},
      autocompleteSchoolsSuggestions: [],
      schoolsInCitySuggestions: [],
      classRoomsSuggestions: null,
    });
  };

  onResetSearch = () => {
    this.setState({
      city: null,

      selectedSchool: null,
      selectedClassRoom: null,

      autocompleteCitySuggestions: {},
      autocompleteSchoolsSuggestions: [],

      schoolsInCitySuggestions: [],
      classRoomsSuggestions: null,
      autocompleteNoResult: false,
      currentRequest: null,
    });
  };

  onCityChange = event => {
    if (event.target.value === '') {
      this.onResetSearch();
    } else {
      this.setState({ city: event.target.value });

      if (event.target.value.length > StartAutocompleteAtLength) {
        this.fetchData(event.target.value);
      } else {
        this.setState({
          autocompleteCitySuggestions: {},
          // autocompleteSchoolsSuggestions?
        });
      }
    }
  };

  onSelectCity = (city, schoolsInCitySuggestions) => () => {
    this.setState({
      city,
      schoolsInCitySuggestions,

      autocompleteCitySuggestions: {},
      autocompleteSchoolsSuggestions: [],
      classRoomsSuggestions: null,
    });
  };

  onSelectSchool = (event, school) => {
    this.setState({
      selectedSchool: school,
      classRoomsSuggestions: school.class_rooms,
    });
  };

  onSelectSchoolFromAutocomplete = school => {
    this.setState({
      city: school.city,
      schoolsInCitySuggestions: [school],

      autocompleteCitySuggestions: {},
      autocompleteSchoolsSuggestions: [],

      selectedSchool: school,
      classRoomsSuggestions: school.class_rooms,
    });
  };

  renderAutocompleteInput = () => {
    const {
      city,
      autocompleteCitySuggestions,
      autocompleteSchoolsSuggestions,
      currentRequest,
      requestError,
      autocompleteNoResult,
    } = this.state;

    const { resourceName, existingSchool, label, required, classes } = this.props;
    return (
      <div className="form-group custom-label-container">
        <div className="input-group">
          <input
            className={`form-control ${classes || ''} ${autocompleteNoResult ? '' : 'rounded-0'}`}
            required={required}
            autoComplete="off"
            placeholder="Rechercher par ville ou par nom"
            type="text"
            name={`${resourceName}[school][city]`}
            id={`${resourceName}_school_city`}
            value={this.currentCityString()}
            onChange={this.onCityChange}
          />
          <label htmlFor={`${resourceName}_school_city`}>
            {label}
            <abbr title="(obligatoire)" aria-hidden="true">
              *
            </abbr>
          </label>

          <div className="input-group-append">
            {!currentRequest && (
              <button
                type="button"
                className={`btn btn-outline-secondary btn-clear-city ${
                  autocompleteNoResult ? '' : 'rounded-0'
                }`}
                onClick={this.onResetSearch}
              >
                <i className="fas fa-times" />
              </button>
            )}
            {currentRequest && (
              <button
                type="button"
                className="btn btn-outline-secondary btn-clear-city"
                onClick={this.onResetSearch}
              >
                <i className="fas fa-spinner fa-spin" />
              </button>
            )}
          </div>
        </div>

        <ul className={`${classes || ''} list-group p-0 shadow-sm autocomplete-school-results`}>
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
              onClick={this.onSelectCity(currentCity, autocompleteCitySuggestions[currentCity])}
            >
              <span dangerouslySetInnerHTML={{ __html: currentCity }} />
              <span className="badge-secondary badge-pill small">
                {autocompleteCitySuggestions[currentCity].length} collège
                {autocompleteCitySuggestions[currentCity].length > 1 ? 's' : ''}
              </span>
            </li>
          ))}

          <li
            className={`list-group-item  list-group-item-secondary small py-2 ${
              (autocompleteSchoolsSuggestions || []).length > 0 ? '' : 'd-none'
            }`}
          >
            Collège(s)
          </li>
          {(autocompleteSchoolsSuggestions || []).map(currentSchool => (
            <li
              type="button"
              className="list-group-item list-group-item-action text-left"
              key={currentSchool.id}
              onClick={event => this.onSelectSchoolFromAutocomplete(currentSchool)}
            >
              <span dangerouslySetInnerHTML={{ __html: currentSchool.pg_search_highlight_name }} />
              <br />
              <small>
                {currentSchool.city} – {currentSchool.zipcode}
              </small>
            </li>
          ))}
          {requestError && (
            <li className="list-group-item list-group-item-danger small">{requestError}</li>
          )}
          {autocompleteNoResult && (
            <li className="list-group-item list-group-item-info small">
              Aucun résultat pour votre recherche. Assurez-vous que l’établissement renseigné est un
              collège REP ou REP+.
            </li>
          )}
        </ul>
      </div>
    );
  };

  renderSchoolsInput = () => {
    const { selectedSchool, schoolsInCitySuggestions } = this.state;
    const { resourceName, existingSchool, classes } = this.props;

    const isWaitingCitySelection =
      schoolsInCitySuggestions.length === 0 && !selectedSchool && !existingSchool;
    const isAlreadySelected = schoolsInCitySuggestions.length === 0 && existingSchool;
    const hasPendingSuggestion = schoolsInCitySuggestions.length > 0;

    return (
      <div className={`form-group ${isWaitingCitySelection ? 'opacity-05' : ''}`}>
        {isWaitingCitySelection && (
          <div class="custom-label-container">
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
                  onChange={event => this.onSelectSchool(event, school)}
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

  renderClassRoomsInput = () => {
    const { selectedClassRoom, classRoomsSuggestions } = this.state;
    const { resourceName, existingClassRoom, classes } = this.props;

    const isWaitingSchoolSelection =
      classRoomsSuggestions === null && !selectedClassRoom && !existingClassRoom;
    const isAlreadySelected = classRoomsSuggestions === null && existingClassRoom;
    const hasPendingSuggestion = classRoomsSuggestions && classRoomsSuggestions.length > 0;

    return (
      <div className={`form-group custom-label-container ${isWaitingSchoolSelection ? 'opacity-05' : ''}`}>

        {isWaitingSchoolSelection && (
          <input
            value=""
            disabled
            className={`form-control ${classes || ''}`}
            type="text"
            id={`${resourceName}_class_room_id`}
          />
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
            <input
              value={existingClassRoom.id}
              type="hidden"
              name={`${resourceName}[class_room_id]`}
            />
          </>
        )}

        {hasPendingSuggestion && (
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
        )}
        {classRoomsSuggestions && classRoomsSuggestions.length === 0 && (
          <input
            placeholder="Aucune classe disponible"
            readOnly
            name={`${resourceName}[class_room_id]`}
            id={`${resourceName}_class_room_id`}
            value=""
            className={`form-control ${classes || ''}`}
            type="text"
          />
        )}
        <label htmlFor={`${resourceName}_class_room_id`}>Classe</label>
      </div>
    );
  };

  render() {
    const { selectClassRoom } = this.props;
    const { city } = this.state;

    return (
      <div className="autocomplete-school-container">
        {this.renderAutocompleteInput()}
        {city !== null && (
          <>
            {this.renderSchoolsInput()}
            {selectClassRoom && this.renderClassRoomsInput()}
          </>
        )}
      </div>
    );
  }
}

export default AutocompleteSchool;
