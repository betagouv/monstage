import React, { useState } from 'react';
import Turbolinks from 'turbolinks';

function FilterInternshipOffer() {
  const searchParams = new URLSearchParams(window.location.search);
  const initialSchoolType = searchParams.get('school_type');
  const [schoolType, setSchoolType] = useState(searchParams.get('school_type'));

  // clear selected radio
  const clearRadioOnDoubleClick = (event) => {
    if (schoolType !== null && event.target.value === schoolType) {
      setSchoolType(null);
      searchParams.delete('school_type');
      Turbolinks.visit(`${window.location.pathname}?${searchParams.toString()}`);
      event.preventDefault();
    }
    return event;
  }

  // switch radio
  const filterOffers = (event) => {
   setSchoolType(event.target.value)
   if (event.target.value) {
      searchParams.set('school_type', event.target.value);
    } else {
      searchParams.delete('school_type');
    }
    Turbolinks.visit(`${window.location.pathname}?${searchParams.toString()}`);
  }

  return (
    <div className="form-group form-inline justify-content-center justify-content-sm-start justify-content-md-center p-0 m-0 custom-radio-boxes">
      <span className="font-weight-normal mr-1">Filtrer par : </span>
      <div className='custom-radio-box-control custom-radio-box-control-prepend '>
        <input
          type="radio"
          name="school_type"
          checked={schoolType === 'middle_school'}
          value="middle_school"
          onClick={(event) => clearRadioOnDoubleClick(event)}
          onChange={(event) => filterOffers(event)}
          className="custom-radio-box-control-input"
          id="search-by-middle-school"
        />
        <label className="label mb-0" htmlFor="search-by-middle-school">
          Collège
        </label>
      </div>
      <div className="custom-radio-box-control  custom-radio-box-control-append">
        <input
          type="radio"
          name="school_type"
          value="high_school"
          checked={schoolType === 'high_school'}
          onClick={(event) => clearRadioOnDoubleClick(event)}
          onChange={(event) => filterOffers(event)}
          className="custom-radio-box-control-input"
          id="search-by-high-school"
        />
        <label className="label mb-0" htmlFor="search-by-high-school">
          Lycée
        </label>
      </div>
    </div>
  );
}
export default FilterInternshipOffer;
