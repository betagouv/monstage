import React from 'react';
import DistanceIcon from '../icons/DistanceIcon';

import { MAX_RADIUS, MIN_RADIUS, radiusPercentage, radiusInKm } from '../../utils/geo';

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
          <DistanceIcon radius={radius} />
        </div>
      </div>
    </div>
  );
}
export default RadiusInput;
