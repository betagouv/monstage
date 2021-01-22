PRISMIC_URL = 'https://monstage.cdn.prismic.io/api'
token = Rails.application.credentials.prismic[:api_key]
PrismicClient = Prismic.api(PRISMIC_URL, token)
