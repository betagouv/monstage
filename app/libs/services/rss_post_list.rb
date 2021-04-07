module Services
  require 'open-uri'
  class PartnerPosts
    def get_news
      new_array = RssReader.new(url: partner[:rss_url]).parse
      new_array.inject([]) do |sum, obj|
        single_news = SinglePost.new(
          partner: partner[:name],
          logo: partner[:logo],
          summary: obj[:summary],
          published_at: obj[:published],
          title: obj[:title]
        )
        sum << single_news
      end
    end

    private

    attr_accessor :partner_news, :partner

    def initialize(partner:)
      @partner = partner
    end
  end

  class SinglePost
    attr_reader :summary, :published_at, :partner, :logo, :title, :document

    def fetch_original_article_url
      document.css('p a')
              .first
              .attr('href')
    end

    def fetch_blog_url
      document.css('p a')[1]
              .attr('href')
    end

    def fetch_article_img
      return nil if fetch_original_article_url.nil?

      article = Nokogiri::HTML.parse(open(fetch_original_article_url))
      img_src = article.css('.elementor-image img').first
      return nil if img_src.nil?

      img_src.attr('src')
    end

    private

    def initialize(summary:, published_at:, partner:, logo:, title:)
      @summary = summary
      @published_at = published_at
      @partner = partner
      @logo = logo
      @title = title
      @document = Nokogiri::HTML.parse(summary.html_safe)
    end
  end

  class RssReader
    def parse
      feed = Feedjira.parse get_rss_feed.force_encoding('UTF-8')
      feed.entries
    end

    private

    attr_reader :url

    def get_rss_feed
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.port.to_i == 443)
      http.get(uri).body
    end

    def initialize(url:)
      @url = url
    end
  end

  class RssPostList
    PARTNERS = [
      { name: 'jobirl',
        logo: 'Logo-jobirl-color.png',
        rss_url: 'https://www.jobirl.com/blog/feed/'},
      {  name: 'telemaque',
         logo: 'Logo-telemaque-color.png',
         rss_url: 'https://www.telemaque.org/feed/' },
    ]

    def fetch_news_list
      self.news_list = PARTNERS.inject([]) do |sum, partner|
        sum += PartnerPosts.new(partner: partner).get_news
      end
    end

    def ordered_by_publication_date
      news_list.sort_by(&:published_at)
               .reverse
    end

    attr_accessor :news_list

    private

    def initialize
      @news_list || fetch_news_list
    end
  end
end
