import Turbolinks from 'turbolinks';
import $ from 'jquery';

export const changeURLFromEvent = (event, param) => {
  visitURLWithParam(param, $(event.target).val());
}

export const visitURLWithParam = (param, paramValue) => {
  const searchParamsToClear = ['school_id', 'page']
  const searchParams = clear(searchParamsToClear)
  // other search params are kept as they were
  if (paramValue.length === 0) {
    searchParams.delete(param);
  } else {
    searchParams.set(param, paramValue);
  }
  turboVisitsWithSearchParams(searchParams)
}

export const visitURLWithOneParam = (param, paramValue) => {
  const searchParams = clearAllParams();
  searchParams.set(param, paramValue);
  turboVisitsWithSearchParams(searchParams);
}

export const clearSearch = () => {
  turboVisitsWithSearchParams(clearAllParams());
}

export const turboVisitsWithSearchParams = (searchParams) => {
  Turbolinks.visit(
    `${window.location.origin}${window.location.pathname}?${searchParams.toString()}`,
  );
}

export const clearParamAndVisits = (param_name )=> {
  const searchParams = getSearchParams();
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

// private

const getSearchParams = () => {
  return new URLSearchParams(window.location.search);
}

const clear = (list) => {
  const searchParams = getSearchParams();
  for (const param of list) {
    searchParams.delete(param)
  }
  return searchParams;
}

const clearAllParams = () => {
  const searchParams = getSearchParams();
  for (const param of searchParams.keys()) {
    searchParams.delete(param)
  }
  return searchParams;
}