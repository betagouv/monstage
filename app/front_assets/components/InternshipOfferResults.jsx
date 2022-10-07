import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, useMap, Marker, Popup } from 'react-leaflet';
import MarkerClusterGroup from 'react-leaflet-cluster';

import activeMarker from '../images/active_pin.svg';
import defaultMarker from '../images/default_pin.svg';
import InternshipOfferCard from './InternshipOfferCard';
import CardLoader from './CardLoader';
import FilterModal from './search_internship_offer/FilterModal';
import Paginator from './search_internship_offer/Paginator';
import TitleLoader from './TitleLoader';
import { endpoints } from '../utils/api';
import { isMobile } from '../utils/responsive';

const center = [48.866669, 2.33333]; // ANCT

const pointerIcon = new L.Icon({
  iconUrl: activeMarker,
  iconSize: [50, 58], // size of the icon
  iconAnchor: [20, 58], // changed marker icon position
  popupAnchor: [0, -60], // changed popup position
});

const defaultPointerIcon = new L.Icon({
  iconUrl: defaultMarker,
  iconSize: [50, 58], // size of the icon
  iconAnchor: [20, 58], // changed marker icon position
  popupAnchor: [0, -60], // changed popup position
});

const InternshipOfferResults = ({ count, sectors, params }) => {
  // const [map, setMap] = useState(null);
  const [selectedOffer, setSelectedOffer] = useState(null);
  const [paginateLinks, setPaginateLinks] = useState(null);
  const [internshipOffers, setInternshipOffers] = useState([]);
  const [showSectors, setShowSectors] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [newDataFetched, setNewDataFetched] = useState(false);
  const [selectedSectors, setSelectedSectors] = useState([]);
  const [internshipOffersSeats, setInternshipOffersSeats] = useState(0);

  useEffect(() => {
    requestInternshipOffers();
  }, []);

  const ClickMap = ({ internshipOffers, recenterMap }) => {
    if (isMobile()) {return null };

    if (internshipOffers.length && recenterMap) {
      const map = useMap();
      const bounds = internshipOffers.map((internshipOffer) => [
        internshipOffer.lat,
        internshipOffer.lon,
      ]);
      map.fitBounds(bounds);
      L.tileLayer.provider('CartoDB.Positron').addTo(map);
    }

    setNewDataFetched(false);
    return null;
  };

  const handleMouseOver = (data) => {
    setSelectedOffer(data);
  };

  const handleMouseOut = () => {
    // setSelectedOffer(null);
  };

  const getSectors = () => {
    const sectors = [];
    var clist = document.getElementsByClassName("checkbox-sector");
    for (var i = 0; i < clist.length; ++i) {
      if (clist[i].checked) {
        sectors.push(clist[i].getAttribute('data-sector-id'));
      };
    };
    setSelectedSectors(sectors);
    return sectors;
  }

  const requestInternshipOffers = () => {
    setIsLoading(true);
    document.getElementById("fr-modal-filter").classList.remove("fr-modal--opened");
    document.getElementById("filter-sectors-button").setAttribute('data-fr-opened', false);
    params['sector_ids'] = getSectors();

    $.ajax({ type: 'GET', url: endpoints['searchInternshipOffers'](), data: params })
      .done(fetchDone)
      .fail(fetchFail);
  };

  const fetchDone = (result) => {
    setInternshipOffers(result['internshipOffers']);
    setPaginateLinks(result['pageLinks']);
    setInternshipOffersSeats(result['seats']);

    setIsLoading(false);
    setNewDataFetched(true);

    // if (internshipOffers.length) {
    //   resizingMap
    // }
    return true
  };

  const fetchFail = (xhr, textStatus) => {
    if (textStatus === 'abort') {
      return;
    }
    // setRequestError('Une erreur est survenue, veuillez ré-essayer plus tard.');
  };

  const clearSectors = () => {
    setShowSectors(false);
    var checkboxes = document.getElementsByClassName("checkbox-sector");
    for (var checkbox of checkboxes) {
      checkbox.checked = false;
    }
  };


  return (
    <div className="results-container no-x-scroll">
      <div className="row no-x-scroll">
        <div className={`col-${isMobile() ? '12' : '7' } d-flex flex-row-reverse`} style={{ overflowY: 'scroll' }}>

          <div className="results-row fr-mx-2w no-x-scroll hide-scrollbar fr-mt-2w">
            <div className="row fr-p-2w ">
              <div className="col-8 px-0">
                {
                  isLoading ? (
                    <div className="row fr-mb-2w">
                      <TitleLoader/>
                    </div>
                  ) : (
                    <h2 className="h2 mb-0" id="internship-offers-count">
                      <div className="strong fr-ml-2w">{internshipOffersSeats} Offres de stage</div>
                    </h2>
                  )
                }
              </div>
              <div className="col-4 text-right px-0">
                <button className="fr-btn fr-btn--secondary fr-icon-equalizer-line fr-btn--icon-left" data-fr-opened="false" aria-controls="fr-modal-filter" id="filter-sectors-button">
                  Filtrer
                  {
                    selectedSectors.length > 0 ? (
                      <p className="fr-badge fr-badge--success fr-badge--no-icon fr-m-1w">{selectedSectors.length}</p>
                    ) : ''
                  }
                </button>
              </div>

            </div>

            <div> {/* Cards */}
              {
                isLoading ? (
                <div className="row">
                    <div className={`col-${isMobile() ? '12' : '6'}`}>
                    <CardLoader />
                  </div>
                    <div className={`col-${isMobile() ? '12' : '6'}`}>
                    <CardLoader />
                  </div>
                    <div className={`col-${isMobile() ? '12' : '6'}`}>
                    <CardLoader />
                  </div>
                </div>
                ) : (
                  <div>
                  <div className="row mx-0">
                    {
                      internshipOffers.length ? (
                        internshipOffers.map((internshipOffer, i) => (
                          <InternshipOfferCard
                            internshipOffer={internshipOffer}
                            key={internshipOffer.id}
                            index={i}
                            handleMouseOut={handleMouseOut}
                            handleMouseOver={(value) => {handleMouseOver(value)}}
                            />
                        ))

                      ) : (
                        <div>
                          <h6>Aucune offre trouvée... </h6>
                        </div>
                      )
                    }
                  </div>
                  <div>{paginateLinks ? <Paginator paginateLinks={paginateLinks} /> : ''}</div>
                </div>
                )

              }
            </div>
          </div>
        </div>

        {!isMobile() &&(<div className="col-5 map-container">
          <div className="">
            <MapContainer center={center} zoom={13} scrollWheelZoom={false}>
              <TileLayer
                url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
              />
              <MarkerClusterGroup>
                {
                  internshipOffers.length ? (
                    internshipOffers.map((internshipOffer) => (
                      <Marker
                        icon={
                          internshipOffer.id === selectedOffer ? pointerIcon : defaultPointerIcon
                        }
                        position={[internshipOffer.lat, internshipOffer.lon]}
                        key={internshipOffer.id}
                      >
                        <Popup className='popup-custom'>
                          <a href={internshipOffer.link}>
                            <div className="img">
                              <img className="fr-responsive-img" src={internshipOffer.image} alt="image"></img>
                            </div>

                            <div className="content fr-p-2w">
                              <p className="fr-card__detail">{internshipOffer.employer_name}</p>
                              <h6 className="title">
                                {internshipOffer.title}
                              </h6>
                            </div>
                          </a>
                        </Popup>
                      </Marker>
                    ))
                  ) : ('')
                }
              </MarkerClusterGroup>

              <ClickMap internshipOffers={internshipOffers} recenterMap={newDataFetched} />

            </MapContainer>
          </div>
        </div>
        )}
      </div>

      <FilterModal
        sectors={sectors}
        requestInternshipOffers={requestInternshipOffers}
        clearSectors={clearSectors}
      />
    </div>
  );
};

export default InternshipOfferResults;