class PrismicFinder
  def self.homepage
    PrismicClient.query(Prismic::Predicates.at("document.type", "homepage")).results[0]
  end
end
