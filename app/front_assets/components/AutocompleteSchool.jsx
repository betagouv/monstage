import React from 'react';
import PropTypes from 'prop-types';
import $ from 'jquery';

const StartAutocompleteAtLength = 2;
import SchoolPropType from '../prop_types/school';

class AutocompleteSchool extends React.Component {
  static propTypes = {
    label: PropTypes.string.isRequired,
    required: PropTypes.bool.isRequired,
    resourceName: PropTypes.string.isRequired,
    selectClassRoom: PropTypes.bool.isRequired,
    existingSchool: PropTypes.objectOf(SchoolPropType),
    existingClassRoom: PropTypes.objectOf(PropTypes.object),
  };

  static defaultProps = {
    existingSchool: null,
    existingClassRoom: null,
  };

  state = {
    currentRequest: null,l
    requestError: null,

    selectedSchool: null,
    selectedClassRoom: null,

    city: '',
    citySuggestions: {},
    schoolsSuggestions: [],
    classRoomsSuggestions: [],
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
      citySuggestions: result,
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
      citySuggestions: {},
      schoolsSuggestions: [],
      classRoomsSuggestions: [],
    });
  };

  onResetSearch = () => {
    this.setState({
      city: '',

      selectedSchool: null,
      selectedClassRoom: null,

      citySuggestions: {},
      schoolsSuggestions: [],
      classRoomsSuggestions: [],
    });
  };

  onCityChange = event => {
    this.setState({ city: event.target.value });

    if (event.target.value.length > StartAutocompleteAtLength) {
      this.fetchData(event.target.value);
    } else {
      this.setState({ citySuggestions: {} });
    }
  };

  onSelectCity = (city, schoolsSuggestions) => () => {
    this.setState({
      city,
      schoolsSuggestions,

      citySuggestions: {},
      classRoomsSuggestions: [],
    });
  };

  onSelectSchool = (event, school) => {
    this.setState({
      selectedSchool: school,
      classRoomsSuggestions: school.class_rooms,
    });
  };

  renderCityInput = () => {
    const { city, citySuggestions, currentRequest, requestError } = this.state;
    const { resourceName, existingSchool, label, required } = this.props;
    return (
      <div className="form-group">
        <div className="col-12">
          <label htmlFor={`${resourceName}_school_city`}>
            {label}
            <abbr title="(obligatoire)" aria-hidden="true">
              *
            </abbr>
          </label>
          <div className="input-group">
            <input
              className="form-control"
              required={required}
              autoComplete="off"
              placeholder="Rechercher la ville"
              type="text"
              name={`${resourceName}[school][city]`}
              id={`${resourceName}_school_city`}
              value={
                city.length === 0 && existingSchool
                  ? existingSchool.city
                  : city.replace(/<b>/g, '').replace(/<\/b>/g, '')
              }
              onChange={this.onCityChange}
            />
            <div className="input-group-append">
              {!currentRequest && (
                <button
                  type="button"
                  className="btn btn-outline-secondary btn-clear-city"
                  onClick={this.onResetSearch}
                >
                  <i className="fas fa-times" />
                </button>
              )}
              {currentRequest && (
                <button type="button" className="btn btn-outline-secondary btn-clear-city">
                  <i className="fas fa-spinner fa-spin" />
                </button>
              )}
            </div>
          </div>
        </div>

        <div className="col-12">
          <ul className="list-group { citySuggestions.length > 0 ? '' : 'd-none'}">
            {Object.keys(citySuggestions || {}).map(currentCity => (
              <button
                type="button"
                className="list-group-item text-left"
                key={currentCity}
                onClick={this.onSelectCity(currentCity, citySuggestions[currentCity])}
              >
                <span dangerouslySetInnerHTML={{ __html: currentCity }} />
              </button>
            ))}
          </ul>

          {requestError && <p className="text-danger small">{requestError}</p>}
        </div>
      </div>
    );
  };

  renderSchoolsInput = () => {
    const { selectedSchool, schoolsSuggestions } = this.state;
    const { resourceName, existingSchool } = this.props;

    return (
      <div className="form-group">
        <label>
          Collège
          <abbr title="(obligatoire)" aria-hidden="true">
            *
          </abbr>
        </label>
        {schoolsSuggestions.length === 0 && !selectedSchool && !existingSchool && (
          <input
            value="Veuillez choisir la ville du collège"
            disabled
            className="form-control"
            type="text"
            id={`${resourceName}_school_name`}
          />
        )}
        {schoolsSuggestions.length === 0 && existingSchool && (
          <>
            <input
              readOnly
              disabled
              className="form-control"
              type="text"
              value={existingSchool.name}
              name={`${resourceName}[school_name]`}
              id={`${resourceName}_school_name`}
            />
            <input type="hidden" value={existingSchool.id} name={`${resourceName}[school_id]`} />
          </>
        )}
        {schoolsSuggestions.length > 0 && (
          <div>
            {(schoolsSuggestions || []).map(school => (
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
    const { resourceName, existingClassRoom } = this.props;

    return (
      <div className="form-group">
        <label htmlFor={`${resourceName}_class_room_id`}>Classe</label>
        {classRoomsSuggestions.length === 0 && !selectedClassRoom && !existingClassRoom && (
          <input
            value="Veuillez choisir un collège"
            disabled
            className="form-control"
            type="text"
            id={`${resourceName}_school_name`}
          />
        )}
        {classRoomsSuggestions.length === 0 && existingClassRoom && (
          <>
            <input
              disabled
              readOnly
              className="form-control"
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
        {classRoomsSuggestions.length > 0 && (
          <select
            className="form-control"
            name={`${resourceName}[class_room_id]`}
            id={`${resourceName}_class_room_id`}
          >
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
      </div>
    );
  };

  render() {
    const { selectClassRoom } = this.props;

    return (
      <>
        {this.renderCityInput()}
        {this.renderSchoolsInput()}
        {selectClassRoom && this.renderClassRoomsInput()}
      </>
    );
  }
}



export default AutocompleteSchool;
