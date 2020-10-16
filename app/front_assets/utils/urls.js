import Turbolinks from 'turbolinks';
import $ from 'jquery';

export const changeURLFromEvent = (event, param) => {
  visitURLWithParam(param, $(event.target).val());
}

export const visitURLWithParam = (param, paramValue) => {
  const searchParams = new URLSearchParams(window.location.search);
  if (paramValue.length === 0) {
    searchParams.delete(param);
  } else {
    searchParams.set(param, paramValue);
  }
  searchParams.delete('page');

  turboVisitsWithSearchParams(searchParams)
}

export const turboVisitsWithSearchParams = (searchParams) =>{
  Turbolinks.visit(
    `${window.location.origin}${window.location.pathname}?${searchParams.toString()}`,
  );
}

export const clearParamAndVisits = (fn, param_name )=> {
  fn(null);
  const searchParams = new URLSearchParams(window.location.search);
  searchParams.delete(param_name)
  turboVisitsWithSearchParams(searchParams)
}

export const getParamValueFromUrl = (param) => {
  const searchParams = new URLSearchParams(window.location.search);
  for (const [key, value] of searchParams.entries()) {
    if (key === param) { return value }
  }
  return undefined
}