export const isMobile = () => {
  const vw = Math.max(document.documentElement.clientWidth || 0, window.innerWidth || 0)
  return vw <= 480;
}

export const isTablet = () => {
  const vw = Math.max(document.documentElement.clientWidth || 0, window.innerWidth || 0)
  return (vw <= 767) && (vw >= 480);
}
