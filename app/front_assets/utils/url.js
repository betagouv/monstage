import $ from 'jquery';
import Turbolinks from 'turbolinks';

export const changeURLFromEvent = (event, param, remove_page_param= true) => {
  event.preventDefault();
  const paramValue = $(event.target).val();
  const searchParams = new URLSearchParams(window.location.search);
  if (paramValue.length === 0) {
    searchParams.delete(param);
  } else {
    searchParams.set(param, paramValue);
  }
  if (remove_page_param) {
    searchParams.delete('page');
  }

  Turbolinks.visit(
    `${window.location.origin}${window.location.pathname}?${searchParams.toString()}`,
  );
}