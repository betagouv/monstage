# frozen_string_literal: true

class InternshipOfferKeyword < ApplicationRecord
  include PgSearch::Model

  # InternshipOfferKeywords stores all uniq keywords from internship offer
  # - it's computed via SyncInternshipOfferKeywordsJob
  #   this dict is setup to ignore : email, url, host, file, uint, url_path, sfloat, float, numword, numhword, version;
  #   otherwise it keeps all words, with accents (for nice prompt/search)
  # - it's searchable with pg_trgm for typo tolearant search (we are speaking to Freshman)
  # - it's curated via ActiveAdmin [searchable]
  pg_search_scope :search,
                  against: { word: 'A' },
                  ignoring: :accents,
                  using: :trigram
end
