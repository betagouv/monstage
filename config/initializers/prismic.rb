Rails.application.config.to_prepare do
  PRISMIC_URL = ENV['PRISMIC_URL']
  PRISMIC_TOKEN = ENV['PRISMIC_API_KEY']
  # PrismicClient = Prismic.api(PRISMIC_URL, token)
end
