import React from 'react';
import DistanceIcon from '../icons/DistanceIcon';

import { MAX_RADIUS, MIN_RADIUS, radiusPercentage } from '../../utils/geo';
const COMPONENT_FOCUS_LABEL = 'location';

function RadiusInput({ radius,
                       setRadius,  // used by container
                       focus,
                       setFocus, }) {
  const onRadiusChange = (event) => {
    setRadius(parseInt(event.target.value, 10));
  };
  return (
    <div className="p-3 form-group">
      <label className="font-weight-bold" htmlFor="radius">
        Dans un rayon de
      </label>
      <input
        type="range"
        min={MIN_RADIUS}
        max={MAX_RADIUS}
        id="radius_slider"
        name="radius"
        className="form-control-range form-control px-0"
        value={radius}
        onChange={onRadiusChange}
        onFocus={(event) => {
          setFocus(COMPONENT_FOCUS_LABEL);
        }}
        onBlur={(event) => {
          setFocus(null);
        }}
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
