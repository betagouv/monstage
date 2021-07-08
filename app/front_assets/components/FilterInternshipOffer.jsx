import React, { useState } from 'react';
import { changeURLFromEvent, clearParamAndVisits } from '../utils/urls';

function FilterInternshipOffer({ filterOptions }) {
  const searchParams = new URLSearchParams(window.location.search);
  const [schoolTrack, setSchoolTrack] = useState(searchParams.get('school_track'));

  // clear selected radio
  const clearRadioOnDoubleClick = (event) => {
    if (schoolTrack !== null && event.target.value === schoolTrack) {
      setSchoolTrack(null)
      clearParamAndVisits('school_track')
      event.preventDefault();
    }
    return event;
  }

  // switch radio
  const filterOffers = (event) => {
    setSchoolTrack(event.target.value)
    changeURLFromEvent(event,'school_track')
  }
  return (
    <div className="form-group form-inline justify-content-center p-0 m-0 custom-radio-boxes">
      <span className="font-weight-normal justify-content-sm-center mr-1">{filterOptions.component_label}  </span>
      {filterOptions.options.map(
        function (buttonLabel, index) {
          let extraClass = (index == 0) ? "custom-radio-box-control-prepend" : ""
          extraClass = (index == (filterOptions.options.length - 1)) ? "custom-radio-box-control-append" : extraClass
          return (
            <div className={`custom-radio-box-control d-none d-sm-block ${extraClass}`} key={index}>
              <input
                type="radio"
                name="school_track"
                checked={schoolTrack === buttonLabel.value}
                value={buttonLabel.value}
                onClick={(event) => clearRadioOnDoubleClick(event)}
                onChange={(event) => filterOffers(event)}
                className="custom-radio-box-control-input col-sm-12"
                id={buttonLabel.id}
              />
              <label className="label mb-0" htmlFor={buttonLabel.id}>
                {buttonLabel.label}
              </label>
            </div>
          )
        })
      }
    </div>
  );
}
export default FilterInternshipOffer;
