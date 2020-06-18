# frozen_string_literal: true

# This jobs had been perf tested againt 2019-2020 all offers
#   and run in ±500ms<1s to fetch all words in intership_offers
# All words are extracted from internship_offers
#   title
#   description
#   employer_description
# All words are then simply tokenized with public.config_internship_offer_keywords
# in the end only interesting words are kept to appear in search bar (later, unwanted words will be hidden by searchable)
# computes ndoc (number of ndoc showing it), nentry (count all words)
class SyncInternshipOfferKeywordsJob < ActiveJob::Base
  queue_as :default

  def perform
    if InternshipOffer.count.positive?
      rs = query <<-SQL
        select * from
          ts_stat($$
            SELECT to_tsvector(
              'public.config_internship_offer_keywords',
              CONCAT(
                title, ' ',
                description, ' ',
                employer_description
              )
            )
            FROM internship_offers
          $$)
          ORDER BY ndoc DESC
      SQL
      InternshipOfferKeyword.upsert_all(rs.to_a, unique_by: %w[word])
    end
    InternshipOfferKeyword.qualify_words
  end

  def query(sql)
    ActiveRecord::Base.connection.execute(sql)
  end
end
