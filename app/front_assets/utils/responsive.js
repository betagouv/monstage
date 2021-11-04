function isMobile() {
  const vw = Math.max(document.documentElement.clientWidth || 0, window.innerWidth || 0)
  return vw <= 480;
}
export default isMobile;
