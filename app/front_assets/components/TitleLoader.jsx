import React from "react"
import ContentLoader from "react-content-loader"

const TitleLoader = (props) => (
  <ContentLoader 
    speed={2}
    width={300}
    height={30}
    viewBox="0 0 300 30"
    backgroundColor="#f3f3f3"
    foregroundColor="#ecebeb"
    {...props}
  >
    <rect x="0" y="0" rx="3" ry="3" width="300" height="30" />
  </ContentLoader>
)

export default TitleLoader