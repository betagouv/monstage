export const showElement = ($element) => $element.removeClass('d-none');
export const hideElement = ($element) => $element.addClass('d-none');
export const toggleElement = ($element) => $element.toggleClass('d-none');
export const setElementVisibility = ($element, isVisible) => $element.toggleClass('d-none', isVisible);
