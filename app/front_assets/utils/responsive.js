export const isMobile = () => {
  const MAX_SIZE_FOR_MOBILE = 480;
  const vw = Math.min(document.documentElement.clientWidth || MAX_SIZE_FOR_MOBILE + 1, window.innerWidth || MAX_SIZE_FOR_MOBILE + 1, screen.width || MAX_SIZE_FOR_MOBILE + 1);
  return vw <= MAX_SIZE_FOR_MOBILE;
}

export const isTablet = () => {
  if (isMobile()) return false;

  const MAX_SIZE_FOR_TABLET = 1024;
  const vw = Math.min(document.documentElement.clientWidth || MAX_SIZE_FOR_TABLET + 1, window.innerWidth || MAX_SIZE_FOR_TABLET + 1, screen.width || MAX_SIZE_FOR_TABLET + 1);
  return vw <= MAX_SIZE_FOR_TABLET;
}

