# frozen_string_literal: true

class InternshipOfferKeyword < ApplicationRecord
  include PgSearch::Model

  # InternshipOfferKeywords stores all uniq keywords from internship offer
  # https://www.postgresql.org/docs/current/pgtrgm.html
  # - it's computed via SyncInternshipOfferKeywordsJob
  #   this dict is setup to ignore : email, url, host, file, uint, url_path, sfloat, float, numword, numhword, version;
  #   otherwise it keeps all words, with accents (for nice prompt/search)
  # - it's searchable with pg_trgm for typo tolearant search (we are speaking to Freshman)
  # - it's curated via ActiveAdmin [searchable]
  scope :search, lambda {|term|
    quoted_term = ActiveRecord::Base.connection.quote_string(term)
    where('word % :term', term: term)
      .order(Arel.sql("similarity(word, '#{quoted_term}') DESC"))
  }
end
