export const trackEvent = (event, category, action, name, value) => {
  const _paq = window._paq || [];
  _paq.push(['trackEvent', category, action, name, value]);
}
