export const KILO_METER = 1000;
export const MAX_RADIUS = 60000;
export const MIN_RADIUS = 5000;

export function radiusPercentage(radius) {
  return Math.ceil((radius * 100) / MAX_RADIUS);
}

export function radiusInKm(radius) {
  return Math.ceil(radius / KILO_METER);
}
