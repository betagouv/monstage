import React from 'react';
import { radiusInKm } from '../../utils/geo';

function iconForRadius(radius) {
  const comparableRadius = radiusInKm(radius);

  if (comparableRadius < 10) {
    return 'fa-walking';
  }
  if (comparableRadius < 20) {
    return 'fa-bus';
  }
  return 'fa-train';
}

export default function DistanceIcon({ radius }) {
  return (
    <>
      <span className="mr-1" key={radius}>
        <i className={`fas ${iconForRadius(radius)}`} />
      </span>
      <span>{radiusInKm(radius)} km</span>
    </>
  );
}
