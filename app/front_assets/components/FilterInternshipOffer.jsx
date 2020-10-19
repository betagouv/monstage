import React, { useState } from 'react';
import { changeURLFromEvent, clearParamAndVisits } from '../utils/urls';

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

  return (
    <div className="form-group form-inline justify-content-center justify-content-sm-start justify-content-md-center p-0 m-0 custom-radio-boxes">
      <span className="font-weight-normal justify-content-sm-center mr-1">Filtrer par : </span>
      <div className='custom-radio-box-control custom-radio-box-control-prepend '>
        <input
          type="radio"
          name="school_track"
          checked={schoolTrack === 'troisieme_generale'}
          value="troisieme_generale"
          onClick={(event) => clearRadioOnDoubleClick(event)}
          onChange={(event) => filterOffers(event)}
          className="custom-radio-box-control-input col-sm-12"
          id="search-by-troisieme-generale"
        />
        <label className="label mb-0" htmlFor="search-by-troisieme-generale">
          3e générale
        </label>
      </div>
      <div className='custom-radio-box-control custom-radio-box-control'>
        <input
          type="radio"
          name="school_track"
          checked={schoolTrack === 'troisieme_segpa'}
          value="troisieme_segpa"
          onClick={(event) => clearRadioOnDoubleClick(event)}
          onChange={(event) => filterOffers(event)}
          className="custom-radio-box-control-input col-sm-12"
          id="search-by-troisieme-segpa"
        />
        <label className="label mb-0" htmlFor="search-by-troisieme-segpa">
          3e SEGPA
        </label>
      </div>
      <div className='custom-radio-box-control custom-radio-box-control'>
        <input
          type="radio"
          name="school_track"
          checked={schoolTrack === 'troisieme_prepa_metier'}
          value="troisieme_prepa_metier"
          onClick={(event) => clearRadioOnDoubleClick(event)}
          onChange={(event) => filterOffers(event)}
          className="custom-radio-box-control-input col-sm-12"
          id="search-by-troisieme-prepa-metier"
        />
        <label className="label mb-0" htmlFor="search-by-troisieme-prepa-metier">
          3e prépa métier
        </label>
      </div>
      <div className="custom-radio-box-control  custom-radio-box-control-append">
        <input
          type="radio"
          name="school_track"
          value="bac_pro"
          checked={schoolTrack === 'bac_pro'}
          onClick={(event) => clearRadioOnDoubleClick(event)}
          onChange={(event) => filterOffers(event)}
          className="custom-radio-box-control-input col-sm-12"
          id="search-by-bac-pro"
        />
        <label className="label mb-0" htmlFor="search-by-bac-pro">
          Bac Pro
        </label>
      </div>
    </div>
  );
}
export default FilterInternshipOffer;
