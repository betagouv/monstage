import React from "react"
import ContentLoader from "react-content-loader"

const CardLoader = (props) => (
  <ContentLoader 
    speed={2}
    width={260}
    height={420}
    viewBox="0 0 260 420"
    backgroundColor="#f3f3f3"
    foregroundColor="#ecebeb"
    {...props}
  >
    <rect x="0" y="0" rx="3" ry="3" width="260" height="180" /> 
    <rect x="0" y="240" rx="3" ry="3" width="250" height="6" />
    <rect x="0" y="255" rx="3" ry="3" width="250" height="6" />
    <rect x="0" y="270" rx="3" ry="3" width="230" height="6" /> 
    <rect x="0" y="285" rx="3" ry="3" width="180" height="6" /> 
    <rect x="0" y="300" rx="3" ry="3" width="180" height="6" /> 
    
  </ContentLoader>
)

export default CardLoader