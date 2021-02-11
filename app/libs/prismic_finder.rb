class PrismicFinder
  def self.homepage
    Prismic
      .api(PRISMIC_URL, PRISMIC_TOKEN)
      .query(Prismic::Predicates.at("document.type", "homepage")).results[0]
  end
end
