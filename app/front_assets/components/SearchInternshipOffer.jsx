import React from 'react';
import PropTypes from 'prop-types';
import AlgoliaPlaces from 'algolia-places-react';

import Turbolinks from 'turbolinks';
import $ from 'jquery';

import SchoolPropType from '../prop_types/school';

class SearchInternshipOffer extends React.Component {
  static propTypes = {
    url: PropTypes.string.isRequired,
    algoliaApiId: PropTypes.string.isRequired,
    algoliaApiKey: PropTypes.string.isRequired,
    currentCitySearch: PropTypes.string,
    currentSchool: SchoolPropType,
  };

  static defaultProps = {
    currentCitySearch: null,
    currentSchool: null,
  };

  constructor(props) {
    super(props);
    this.state = {
      currentCitySearch: props.currentCitySearch,
    };
  }


  filterOfferByLocation = ({ suggestion }) => {
    const { url } = this.props;
    const searchParams = new URLSearchParams(window.location.search);

    if (suggestion) {
      searchParams.set('city', suggestion.name);
      searchParams.set('latitude', suggestion.latlng.lat);
      searchParams.set('longitude', suggestion.latlng.lng);
    } else {
      searchParams.delete('city');
      searchParams.delete('latitude');
      searchParams.delete('longitude');
    }
    searchParams.delete('page');

    Turbolinks.visit(`${url}?${searchParams.toString()}`);
  };

  toggleSearchByCity = () => {
    const { currentCitySearch } = this.state;
    if (currentCitySearch) {
      this.setState({ currentCitySearch: null });
      this.filterOfferByLocation({ suggestion: null });
    } else {
      this.setState({ currentCitySearch: '' });
    }
  };

  render() {
    const { currentSchool, algoliaApiKey, algoliaApiId } = this.props;
    const { currentCitySearch } = this.state;

    return (
      <div className="row" data-controller="help">
        <div className="col-12 col-md-6 col-lg-4">
          <div className="form-group">
            <label className="mb-3 d-block" htmlFor="input-search-by-city">
              <strong>Autour de</strong>
            </label>
            {currentSchool !== null && currentCitySearch === null && (
              <div className="input-group">
                <input
                  className="form-control"
                  name="input-search-by-city"
                  id="input-search-by-city"
                  type="text"
                  readOnly
                  value={currentSchool.name}
                />
                <div className="input-group-append">
                  <button
                    type="button"
                    className="btn btn-outline-secondary btn-clear-city"
                    onClick={this.toggleSearchByCity}
                  >
                    <i className="fas fa-times" />
                  </button>
                </div>
              </div>
            )}
            {(currentSchool === null || currentCitySearch !== null) && (
              <div className="input-group">
                <AlgoliaPlaces
                  placeholder={currentCitySearch || 'Rechercher une ville'}
                  options={{
                    appId: algoliaApiId,
                    apiKey: algoliaApiKey,
                    language: 'fr',
                    countries: ['fr'],
                    type: 'city',
                  }}
                  onChange={this.filterOfferByLocation}
                  onClear={this.toggleSearchByCity}
                  onError={({ message }) =>
                    console.log(
                      'Fired when we could not make the request to Algolia Places servers for any reason but reaching your rate limit.',
                    )
                  }
                />
                <div className="input-group-append">
                  <button
                    type="button"
                    className="btn btn-outline-secondary btn-clear-city"
                    onClick={this.toggleSearchByCity}
                  >
                    <i className="fas fa-times" />
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    );
  }
}

export default SearchInternshipOffer;
