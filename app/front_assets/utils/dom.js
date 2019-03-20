export const showElement = (domElement) => domElement.classList.remove('d-none');
export const hideElement = (domElement) => domElement.classList.add('d-none');
export const toggleElement = (domElement) => domElement.classList.toggle('d-none');
export const setElementVisibility = (domElement, isVisible) => domElement.classList.toggle('d-none', isVisible);
