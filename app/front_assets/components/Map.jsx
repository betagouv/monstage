import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, useMap, Marker, Popup } from 'react-leaflet';
import MarkerClusterGroup from 'react-leaflet-cluster';

import defaultMarker from '../images/corporate_pin.svg';
// TODO isMobile n'est pas utilisé
import { isMobile } from '../utils/responsive';

const defaultPointerIcon = new L.Icon({
  iconUrl: defaultMarker,
  iconSize: [50, 58], // size of the icon
  iconAnchor: [20, 58], // changed marker icon position
  popupAnchor: [0, -60], // changed popup position
});

const Map = ({ internshipOffer }) => {
  // TODO isLoading et setIsLoading ne sont pas utilisés
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {  
  }, []);

  return (
    <div className="row fr-my-2w">
      <div className="col-12 map-container-offer">
        <MapContainer center={[internshipOffer.lat, internshipOffer.lon]} zoom={13} scrollWheelZoom={false}>
          <TileLayer
            url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
          />
          <MarkerClusterGroup>
            <Marker
              icon={
                defaultPointerIcon
              }
              position={[internshipOffer.lat, internshipOffer.lon]}
              key={internshipOffer.id}
            >
            </Marker>
          </MarkerClusterGroup>
        </MapContainer>
      </div>
    </div>
  );
};

export default Map;
