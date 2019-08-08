import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types';

const StartAutocompleteAtLength = 2

class AutocompleteSchool extends React.Component {
  state = {
    currentRequest: null,
    requestError: null,

    selectedSchool: null,
    selectedClassRoom: null,

    city: "",
    citySuggestions: {},
    schoolsSuggestions: [],
    classRoomsSuggestions: []
  };

  constructor(props) {
    super(props);
    this.emitRequest = this.emitRequest.bind(this)
    this.fetchDone = this.fetchDone.bind(this)
    this.fetchFail = this.fetchFail.bind(this)
  }

  fetchData = (cityName) => {
    const { currentRequest } = this.state;

    if (currentRequest) {
      this.setState({currentRequest: null}, () => {
        currentRequest.abort();
        this.emitRequest(cityName)
      })
    } else {
      this.emitRequest(cityName)
    };
  }

  emitRequest = (cityName) => {
    this.setState({
      currentRequest: $.ajax({ type: "POST", url: '/api/schools/search', data: {query: cityName}})
                       .done(this.fetchDone)
                       .fail(this.fetchFail)
    })
  }

  fetchDone = (result) => {
    this.setState({
      citySuggestions: result,
      requestError: null,
      currentRequest: null
    })
  }

  fetchFail = (xhr, textStatus) => {
    if (textStatus == "abort") {
      return
    }
    this.setState({
      requestError: "Une erreur est survenue, veuillez ré-essayer plus tard.",
      currentRequest: null,
      citySuggestions: {},
      schoolsSuggestions: [],
      classRoomsSuggestions: []
    });
  }

  onResetSearch = (event) => {
    this.setState({
      city: "",

      selectedSchool: null,
      selectedClassRoom: null,

      citySuggestions: {},
      schoolsSuggestions: [],
      classRoomsSuggestions: []
    })
  }

  onCityChange = (event) => {
    this.setState({city: event.target.value});

    if (event.target.value.length > StartAutocompleteAtLength) {
      this.fetchData(event.target.value)
    } else {
      this.setState({citySuggestions: {}})
    }
  }

  onSelectCity = (city, schoolsSuggestions) => (event) => {
    this.setState({
      city: city,
      schoolsSuggestions,

      citySuggestions: {},
      classRoomsSuggestions: [],
      classRoomsSuggestions: []
    })
  }

  onSelectSchool = (event, school) => {
    this.setState({
      selectedSchool: school,
      classRoomsSuggestions: school.class_rooms
    })
  }

  renderCityInput = () => {
    const {
      city,
      citySuggestions,
      currentRequest,
      requestError
    } = this.state;
    const { resourceName, existingSchool, label, required } = this.props;

    return (
      <div className="form-group">
          <div className="row">
            <div className="col-12">
              <label htmlFor={`${resourceName}_school_city`}>
                {label}
                <abbr title="(obligatoire)" aria-hidden="true">*</abbr>
              </label>
              <div className="input-group">
                <input className="form-control"
                       required={required}
                       autoComplete="off"
                       placeholder="Rechercher la ville"
                       type="text"
                       name={`${resourceName}[school][city]`}
                       id={`${resourceName}_school_city`}
                       value={city.length == "" && existingSchool ? existingSchool.city : city.replace(/<b>/g, '').replace(/<\/b>/g, "")}
                       onChange={this.onCityChange}
                />
                <div className="input-group-append">
                  { !currentRequest && (<button type="button"
                                                className="btn btn-outline-secondary btn-clear-city"
                                                onClick={this.onResetSearch}
                                                >
                                          <i className="fas fa-times"></i>
                                       </button>)}
                  { currentRequest && (<button type="button"
                                               className="btn btn-outline-secondary btn-clear-city">
                                        <i className="fas fa-spinner fa-spin"></i>
                                       </button>)}
                </div>
              </div>
            </div>
          </div>

          <div className="row">
            <div className="col-12">
              <ul className="list-group { citySuggestions.length > 0 ? '' : 'd-none'}">
              { Object.keys((citySuggestions || {})).map((city) => (
                <a className="list-group-item"
                   key={city}
                   onClick={this.onSelectCity(city, citySuggestions[city])}>
                   <span dangerouslySetInnerHTML={{__html: city}} />
                </a>
              )) }
              </ul>

              { requestError && <p className="text-danger small">{requestError}</p> }
            </div>
          </div>
        </div>
    )
  }

  renderSchoolsInput = () => {
    const { selectedSchool, schoolsSuggestions } = this.state;
    const { resourceName, existingSchool } = this.props;

    return (
      <div className="form-group">
        <label>
          Collège
          <abbr title="(obligatoire)" aria-hidden="true">*</abbr>
        </label>
        { schoolsSuggestions.length == 0 && !selectedSchool && !existingSchool && (
          <input value="Veuillez choisir la ville du collège"
                 disabled
                 className="form-control"
                 type="text"
                 id={`${resourceName}_school_name`}
          />
        )}
        { schoolsSuggestions.length == 0 && existingSchool && (
          <>
            <input value="{existingSchool.name}"
                   readOnly
                   disabled
                   className="form-control"
                   type="text"
                   value={existingSchool.name}
                   name={`${resourceName}[school_name]`}
                   id={`${resourceName}_school_name`}
            />
            <input value="{existingSchool.id}"
                   type="hidden"
                   value={existingSchool.id}
                   name={`${resourceName}[school_id]`}
            />
          </>
        )}
        { schoolsSuggestions.length > 0 && (
          <div>
            { (schoolsSuggestions || []).map((school) => (
              <div className="custom-control custom-radio"
                   key={`school-${school.id}`}>
                <input type="radio"
                       id={`select-school-${school.id}`}
                       name={`${resourceName}[school_id]`}
                       value={school.id}
                       checked={selectedSchool && selectedSchool.id == school.id}
                       onChange={(event) => this.onSelectSchool(event, school)}
                       required
                       className="custom-control-input"
                />
                <label htmlFor={`select-school-${school.id}`}
                       className="custom-control-label">
                  {school.name}
                </label>
              </div>
            ))}
          </div>
        )}
      </div>
    )
  }

  renderClassRoomsInput = () => {
    const { selectedClassRoom, classRoomsSuggestions } = this.state;
    const { resourceName, existingClassRoom, selectClassRoom } = this.props;

    return (
      <div className="form-group">
        <label htmlFor={`${resourceName}_class_room_id`}>
          Classe
        </label>
        { classRoomsSuggestions.length == 0 && !selectedClassRoom && !existingClassRoom && (
          <input value="Veuillez choisir un collège"
                 disabled
                 className="form-control"
                 type="text"
                 id={`${resourceName}_school_name`}
          />
        )}
        { classRoomsSuggestions.length == 0 && existingClassRoom && (
          <>
            <input value={existingClassRoom.name}
                   disabled
                   readOnly
                   className="form-control"
                   type="text"
                   value={existingClassRoom.name}
                   name={`${resourceName}[class_room_name]`}
                   id={`${resourceName}_class_room_name`}
            />
            <input value={existingClassRoom.id}
                   type="hidden"
                   name={`${resourceName}[class_room_id]`}
            />
          </>
        )}
        { classRoomsSuggestions.length > 0 && (
          <select className="form-control"
                  name={`${resourceName}[class_room_id]`}
                  id={`${resourceName}_class_room_id`}>
            {(classRoomsSuggestions || []).map((classRoom) => (
              <option key={`class-room-${classRoom.id}`}
                      value={classRoom.id}
                      selected={selectedClassRoom && selectedClassRoom.id == classRoom.id}>
                {classRoom.name}
              </option>
            ))}
          </select>
        )}
      </div>
    )
  }

  render() {
    const { selectClassRoom } = this.props

    return (
      <>
        {this.renderCityInput()}
        {this.renderSchoolsInput()}
        { selectClassRoom && this.renderClassRoomsInput()}
      </>
    )
  }
}

AutocompleteSchool.propTypes = {
  label: PropTypes.string,
  required: PropTypes.bool,
  resourceName: PropTypes.string,
  selectClassRoom: PropTypes.bool,
  existingSchool: PropTypes.object,
  existingClassRoom: PropTypes.object
}

export default AutocompleteSchool
