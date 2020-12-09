import { Controller } from 'stimulus';
import { broadcast, newCoordinatesChanged } from '../utils/events';

export default class extends Controller {
  static targets = ['root']

  connect() {
    const latitude = this.data.get('latitude')
    const longitude = this.data.get('longitude')
    debugger
    console.log('hello')
    broadcast(newCoordinatesChanged({ latitude, longitude }));
  }
}
