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
                unaccent(title), ' ',
                unaccent(description), ' ',
                unaccent(employer_description)
              )
            )
            FROM internship_offers
          $$)
          ORDER BY ndoc DESC
      SQL
      InternshipOfferKeyword.upsert_all(rs.to_a, unique_by: %w[word])
    end
  end

  def query(sql)
    ActiveRecord::Base.connection.execute(sql)
  end
end
