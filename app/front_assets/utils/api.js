const host = `${document.location.protocol}//${document.location.host}`;

export const endpoints = {
  // @post
  apiSchoolsNearby: ({ latitude, longitude }) => {
    const endpoint = new URL(`${host}/api/schools/nearby`);
    const searchParams = new URLSearchParams();

    searchParams.append('latitude', latitude);
    searchParams.append('longitude', longitude);
    endpoint.search = searchParams.toString();

    return endpoint;
  },

  // @get
  apiSearchAddress: ({ fullAddress }) => {
    const endpoint = new URL(`${host}/api_address_proxy/search`);
    const searchParams = new URLSearchParams();

    searchParams.append('q', fullAddress);
    searchParams.append('limit', 10);
    endpoint.search = searchParams.toString();

    return endpoint;
  },

  // @post
  apiInternshipOfferKeywordsSearch: ({ keyword }) => {
    const endpoint = new URL(`${host}/internship_offer_keywords/search`);
    const searchParams = new URLSearchParams();

    searchParams.append('keyword', keyword);
    endpoint.search = searchParams.toString();

    return endpoint;
  },

  // @post
  apiSearchSchool: () => {
    const endpoint = new URL(`${host}/api/schools/search`);
    return endpoint;
  },
};
