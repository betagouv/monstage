import React from 'react';
import PropTypes from 'prop-types';
import AlgoliaPlaces from 'algolia-places-react';

import Turbolinks from 'turbolinks';
import $ from 'jquery';

import SchoolPropType from '../prop_types/school';
import SectorPropType from '../prop_types/sector';

class SearchInternshipOffer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      currentCitySearch: props.currentCitySearch,
    };
  }

  filterOfferBySector = event => {
    const { url } = this.props;
    const paramValue = $(event.target).val();
    const searchParams = new URLSearchParams(window.location.search);

    if (paramValue.length === 0) {
      searchParams.delete('sector_id');
    } else {
      searchParams.set('sector_id', paramValue);
    }

    Turbolinks.visit(`${url}?${searchParams.toString()}`);
  };

  filterOfferByLocation = ({ suggestion }) => {
    const { url } = this.props;
    const searchParams = new URLSearchParams(window.location.search);

    searchParams.set('city', suggestion.name);
    searchParams.set('latitude', suggestion.latlng.lat);
    searchParams.set('longitude', suggestion.latlng.lng);

    Turbolinks.visit(`${url}?${searchParams.toString()}`);
  };

  toggleSearchByCity = () => {
    const { currentCitySearch } = this.state;
    this.setState({ currentCitySearch: currentCitySearch ? null : '' });
  };

  render() {
    const { currentSchool, currentSector, sectors, algoliaApiKey, algoliaApiId } = this.props;
    const { currentCitySearch } = this.state;

    return (
      <>
        <div className="row">
          <div className="form-group">
            <div className="col-12">
              <label htmlFor="input-search-by-city">Autour de</label>
            </div>
            <div className="col-12">
              {currentCitySearch === null && (
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
              {currentCitySearch !== null && (
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
              )}
            </div>
          </div>
        </div>
        <div className="row">
          <div className="form-group" data-controller="help">
            <div className="col-12">
              <label className="mt-2 mb-3 d-block" htmlFor="internship-offer-sector-filter">
                <strong>Secteur professionnel</strong>
                <button
                  type="button"
                  className="btn btn-link py-0"
                  data-action="click->help#toggle"
                >
                  <i className="fa fa-question-circle" />
                </button>
              </label>
            </div>
            <div className="col-12">
              <div
                className="help-sign-content py-1 px-2 mb-3 d-none bg-white alert alert-secondary alert-outlined"
                data-target="help.content"
              >
                {currentSector && (
                  <>
                    Pour en savoir plus sur le secteur professionnel
                    {` "${currentSector.name}"`}
                    <a href={currentSector.external_url}>site de l&apos;Onisep.</a>
                  </>
                )}
                {!currentSector && (
                  <>
                    Pour découvrir les secteurs profesionnels consultez le{' '}
                    <a href="http://www.onisep.fr/Decouvrir-les-metiers/Des-metiers-par-secteur">
                      site de l&apos;Onisep.
                    </a>
                  </>
                )}
              </div>
            </div>
            <div className="col-12">
              <select
                name="Sélectionner un domaine d'activité"
                id="internship-offer-sector-filter"
                className="custom-select col-12"
                onChange={this.filterOfferBySector}
              >
                <option value="">-- Veuillez sélectionner un domaine --</option>
                <option value="">Tous</option>
                {(sectors || []).map(sector => (
                  <option key={sector.id} value={sector.id}>
                    {sector.name}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>
      </>
    );
  }
}

SearchInternshipOffer.propTypes = {
  url: PropTypes.string.isRequired,
  algoliaApiId: PropTypes.string.isRequired,
  algoliaApiKey: PropTypes.string.isRequired,
  sectors: PropTypes.arrayOf(SectorPropType).isRequired,
  currentCitySearch: PropTypes.string,
  currentSector: SectorPropType,
  currentSchool: SchoolPropType,
};

SearchInternshipOffer.defaultProps = {
  currentCitySearch: null,
  currentSchool: null,
  currentSector: null,
};

export default SearchInternshipOffer;
