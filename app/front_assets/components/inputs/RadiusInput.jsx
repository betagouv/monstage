import React from 'react';

const MAX_RADIUS = 60000;
const MIN_RADIUS = 5000;
const KILO_METER = 1000;

function radiusPercentage(radius) {
  return Math.ceil((radius * 100) / MAX_RADIUS);
}
function radiusInKm(radius) {
  return Math.ceil(radius / KILO_METER);
}

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

function RadiusInput({ radius, setRadius }) {
  const onRadiusChange = event => {
    setRadius(parseInt(event.target.value, 10));
  };

  return (
    <div className="p-3">
      <label className="font-weight-bold" htmlFor="radius">
        Dans un rayon de
      </label>
      <input
        type="range"
        min={MIN_RADIUS}
        max={MAX_RADIUS}
        id="radius"
        name="radius"
        className="form-control-range form-control px-0"
        value={radius}
        onChange={onRadiusChange}
        step={5000}
      />
      <div className="slider-legend small">
        <div className="slider-handle text-center" style={{ left: `${radiusPercentage(radius)}%` }}>
          <span className="mr-1">{radiusInKm(radius)} km</span>
          <span key={radius}>
            <i className={`fas ${iconForRadius(radius)}`} />
          </span>
        </div>
      </div>
    </div>
  );
}
export default RadiusInput;
