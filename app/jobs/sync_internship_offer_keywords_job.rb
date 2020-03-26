class SyncInternshipOfferKeywordsJob < ActiveJob::Base
  queue_as :default

  def perform
    if InternshipOffer.count.positive?
      raw(query: "TRUNCATE TABLE internship_offer_keywords")
      rs = raw(query: "select * from ts_stat($$SELECT to_tsvector('french_simple', unaccent(title) || ' ' || unaccent('description') || unaccent('employer_description')) FROM internship_offers$$) ORDER BY ndoc DESC")

      InternshipOfferKeyword.insert_all(rs.to_a)
    end
  end

  def raw(query:)
    ActiveRecord::Base.connection.execute(query)
  end
end
