import { Controller } from 'stimulus';
import { broadcast, newCoordinatesChanged } from '../utils/events';

export default class extends Controller {
  static targets = ['root']
  static values = {
    latitude: Number,
    longitude: Number
  }

  connect() {
    const latitude = this.latitudeValue
    const longitude = this.longitudeValue
    broadcast(newCoordinatesChanged({ latitude, longitude }));
  }
}
