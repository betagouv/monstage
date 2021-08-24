class PrismicFinder
  def self.homepage
    Prismic
      .api(PRISMIC_URL, PRISMIC_TOKEN)
      .query(Prismic::Predicates.at("document.type", "homepage")).results[0]
  end

  def self.blog
    Prismic
      .api(PRISMIC_URL, PRISMIC_TOKEN)
      .query(Prismic::Predicates.at("document.type", "blog_post")).results[0..9]
  end

  def self.blog_post(slug)
    Prismic
      .api(PRISMIC_URL, PRISMIC_TOKEN)
      .query(Prismic::Predicates.at("my.blog_post.uid", slug)).results[0]
  end
end
