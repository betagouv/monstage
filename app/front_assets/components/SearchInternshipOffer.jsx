import React, { useState } from 'react';
import Turbolinks from 'turbolinks';

import CityInput from './inputs/CityInput';
import KeywordInput from './inputs/KeywordInput';

function SearchInternshipOffer({ url, initialLocation, className }) {
  const searchParams = new URLSearchParams(window.location.search);
  // used by keyword input
  const [keyword, setKeyword] = useState(searchParams.get('keyword') || "");
  // used by location input
  const [city, setCity] = useState(searchParams.get('city'));
  const [latitude, setLatitude] = useState(searchParams.get('latitude'));
  const [longitude, setLongitude] = useState(searchParams.get('longitude'));
  const [radius, setRadius] = useState(searchParams.get('radius') || 60000);
  // used by both
  const [focus, setFocus] = useState(null);

  const filterOffers = event => {
    if (city) {
      searchParams.set('city', city);
      searchParams.set('latitude', latitude);
      searchParams.set('longitude', longitude);
      searchParams.set('radius', radius);
    } else {
      searchParams.delete('city');
      searchParams.delete('latitude');
      searchParams.delete('radius');
      searchParams.delete('longitude');
    }

    if (keyword.length > 0) {
      searchParams.set('keyword', keyword);
    } else {
      searchParams.delete('keyword');
    }

    searchParams.delete('page');

    Turbolinks.visit(`${url}?${searchParams.toString()}`);

    if (event) {
      event.preventDefault();
    }
  };

  return (
    <form data-turbolink={false} onSubmit={filterOffers}>
      <div className={`row search-bar ${className}`}>
        <KeywordInput
          keyword={keyword}
          setKeyword={setKeyword}
          focus={focus}
          setFocus={setFocus}
        />
        <CityInput
          city={city}
          longitude={longitude}
          latitude={latitude}

          setCity={setCity}
          setLongitude={setLongitude}
          setLatitude={setLatitude}

          radius={radius}
          setRadius={setRadius}

          focus={focus}
          setFocus={setFocus}
        />

        <div className="input-group-prepend d-flex d-xs-stick no-padding">
          <button
            id='test-submit-search'
            type="submit"
            className="input-group-search-button
                       btn
                       btn-danger
                       btn-xs-sm
                       float-right
                       float-sm-none
                       px-3
                       rounded-xs-0"
          >
            <i className="fas fa-search" />
            &nbsp; Rechercher
          </button>
        </div>
      </div>
    </form>
  );
}
export default SearchInternshipOffer;
