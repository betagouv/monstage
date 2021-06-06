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

// private

const clear = (list) => {
  const searchParams = new URLSearchParams(window.location.search);
  for (var i = 0; i < list.length; i++) {
    searchParams.delete(list[i])
  }
  return searchParams;
}

const clearAllParams = () => {
  const searchParams = new URLSearchParams(window.location.search);
  let list = []
  for (var key of searchParams.keys()) { list.push(key) }
  return clear(list);
}