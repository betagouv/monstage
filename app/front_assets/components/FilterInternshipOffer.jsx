import React, { useState } from 'react';
import { changeURLFromEvent, clearParamAndVisits } from '../utils/urls';
import { useMediaQuery } from 'react-responsive';

function FilterInternshipOffer() {
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
  const isPortrait = useMediaQuery({ orientation: 'portrait' })
  const isMobile = useMediaQuery({ maxWidth: 767 })
  const buttonLabels = [
    { value: 'troisieme_generale', id: 'search-by-troisieme-generale', label: '3ème' },
    { value: 'troisieme_segpa', id: 'search-by-troisieme-segpa', label: '3e SEGPA' },
    { value: 'troisieme_prepa_metiers', id: 'search-by-troisieme-prepa-metiers', label: '3e prépa métiers' },
    { value: 'bac_pro', id: 'search-by-bac-pro', label: 'Bac Pro' },
  ];
  const largeScreenDisplay =
    (<div className="form-group form-inline justify-content-center justify-content-sm-start justify-content-md-center p-0 m-0 custom-radio-boxes">
      <span className="font-weight-normal justify-content-sm-center mr-1">Filtrer par : </span>
      {buttonLabels.map(
        function (buttonLabel, index) {
          let extraClass = (index == 0) ? "custom-radio-box-control-prepend" : ""
          extraClass = (index == (buttonLabels.length - 1)) ? "custom-radio-box-control-append" : extraClass
          return (
            <div className={`custom-radio-box-control d-none d-md-block ${extraClass}`}>
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
  const smallScreenDisplay = (
    <div>
      <p>
        There is the alternate radio component {isPortrait}
      </p>
    </div>
  )
  return (isPortrait && isMobile) ? smallScreenDisplay : largeScreenDisplay
}
export default FilterInternshipOffer;
