import React, { useState } from 'react';
import Turbolinks from 'turbolinks';

import LocationInput from './inputs/LocationInput';
import KeywordInput from './inputs/KeywordInput';

function SearchInternshipOffer({ url, initialLocation }) {
  const searchParams = new URLSearchParams(window.location.search);
  // default holded by url
  const [term, setTerm] = useState(searchParams.get('term') || "");
  const [radius, setRadius] = useState(searchParams.get('radius') || 60000);

  // location is a bit trickier
  const [location, setLocation] = useState(null);
  const [focus, setFocus] = useState(null);
  const filterOffers = event => {
    if (location) {
      searchParams.set('city', location.nom);
      searchParams.set('latitude', location.centre.coordinates[1]);
      searchParams.set('longitude', location.centre.coordinates[0]);
    }

    if (term.length > 0) {
      searchParams.set('term', term);
    } else {
      searchParams.delete('term');
    }
    if (radius) {
      searchParams.set('radius', radius);
    }
    searchParams.delete('page');

    Turbolinks.visit(`${url}?${searchParams.toString()}`);

    if (event) {
      event.preventDefault();
    }
  };

  return (
    <form data-turbolink={false} onSubmit={filterOffers}>
      <div className="row search-bar">
        <KeywordInput
          term={term}
          setTerm={setTerm}
          focus={focus}
          setFocus={setFocus}
        />
        <LocationInput
          setRadius={setRadius}
          radius={radius}
          initialLocation={initialLocation}
          setLocation={setLocation}
          focus={focus}
          setFocus={setFocus}
        />

        <div className="input-group-prepend d-flex d-xs-stick no-padding">
          <button
            type="submit"
            className="input-group-search-button
                       btn
                       btn-warning
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
