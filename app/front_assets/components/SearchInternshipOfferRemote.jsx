import React, { useState, useEffect } from 'react';
import Turbolinks from 'turbolinks';

import findBootstrapEnvironment from '../utils/responsive';

import KeywordInput from './search_internship_offer/KeywordInput';

function SearchInternshipOfferRemote({ url, className, searchWordVisible = true}) {
  const isMobile = findBootstrapEnvironment() == 'xs';
  const searchParams = new URLSearchParams(window.location.search);

  // hand made dirty tracking
  const initialKeyword = searchParams.get('keyword') || '';

  const [showSearch, setShowSearch] = useState(!isMobile);

  // used by keyword input
  const [keyword, setKeyword] = useState(initialKeyword);

  // used by both
  const [focus, setFocus] = useState(null);


  const filterOffers = (event) => {
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

    setShowSearch(keywordChanged);
  };

  if (isMobile) {
    useEffect(dirtyTrackSearch, [keyword]);
  }

  return (
    <form data-turbolink={false} onSubmit={filterOffers}>
      <div className={`row search-bar ${className}`}>
        <KeywordInput keyword={keyword} setKeyword={setKeyword} focus={focus} setFocus={setFocus} />
        {showSearch && (
          <div className="input-group-prepend d-flex d-xs-stick p-0">
            <button
              id="test-submit-search"
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
              &nbsp; {(searchWordVisible) ? "Rechercher" : ""}
            </button>
          </div>
        )}
      </div>
    </form>
  );
}
export default SearchInternshipOfferRemote;
