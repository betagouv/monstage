// used to connect react/stimulus
// listen to event with `attach` on stimulus.connect
//                      (and don't forget to `detach` on stimulus.disconnect)
// beware, keep a reference to the event listener to detail it nicely

// keep list of event formatted here
export const EVENT_LIST = {
  COORDINATES_CHANGED: 'coordinates-changed'
}

// keep event builder here
export const newCoordinatesChanged = ({latitude, longitude}) => {
  return new CustomEvent(EVENT_LIST.COORDINATES_CHANGED, {
    detail: { latitude: latitude,
              longitude: longitude }
  });
}

// use default DOM event model
export const attach = (eventName, handler) => document.addEventListener(eventName, handler)
export const detach = (eventName, handler) => document.removeEventListener(eventName, handler)
export const broadcast = (event) => document.dispatchEvent(event)
