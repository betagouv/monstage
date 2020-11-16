const host = `${document.location.protocol}//${document.location.host}`

export const endpoints = {
  // @post
  apiSchoolsNearby: ({latitude, longitude}) => {
    let endpoint =  new URL(`${host}/api/schools/nearby`)

    const searchParams = new URLSearchParams();

    searchParams.append('latitude', latitude)
    searchParams.append('longitude', longitude)
    endpoint.search = searchParams.toString();
    return endpoint
  }
}
