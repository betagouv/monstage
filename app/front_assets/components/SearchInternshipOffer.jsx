import React, { useState, useEffect } from 'react';
import Turbolinks from 'turbolinks';

import CityInput from './inputs/CityInput';
import KeywordInput from './inputs/KeywordInput';

import findBootstrapEnvironment from '../utils/responsive';

function SearchInternshipOffer({ url, initialLocation, className }) {
  const isMobile = findBootstrapEnvironment() == 'xs';
  const searchParams = new URLSearchParams(window.location.search);

  // hand made dirty tracking
  const initialKeyword = searchParams.get('keyword') || "";
  const initialLatitude = searchParams.get('latitude');
  const initialLongitude = searchParams.get('longitude');
  const [showSearch, setShowSearch] = useState(!isMobile);

  // used by keyword input
  const [keyword, setKeyword] = useState(initialKeyword);
  // used by location input
  const [city, setCity] = useState(searchParams.get('city'));
  const [latitude, setLatitude] = useState(initialLatitude);
  const [longitude, setLongitude] = useState(initialLongitude);
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

  // on mobile, only show button when needed
  // maybe disable it on desktop when no change can be applied?
  const dirtyTrackSearch = () => {
    const keywordChanged = initialKeyword != keyword;
    const coordinatesChanged = initialLatitude != latitude || initialLongitude != longitude;

    setShowSearch(keywordChanged || coordinatesChanged)
  }

  if(isMobile) {
    useEffect(dirtyTrackSearch, [latitude, longitude, keyword]);
  }

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
        {showSearch && (
          <div className={`input-group-prepend d-flex d-xs-stick no-padding`}>
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
          )}
      </div>
    </form>
  );
}
export default SearchInternshipOffer;
