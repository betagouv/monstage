class InternshipOfferKeyword < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search,
                  against: {word:'A'},
                  ignoring: :accents,
                  using: :trigram
end
