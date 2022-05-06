# frozen_string_literal: true

class InternshipOfferKeyword < ApplicationRecord
  include PgSearch::Model

  REJECTED_NATURES = [
    'adj. poss.',
    'adj. numér. cardinal',
    'adv.',
    'adv. de manière',
    'article défini',
    'articles',
    'conj. de coord',
    'conj. de sub.',
    'impers. et pron.',
    'pr. adverbial',
    'pr. interr.',
    'pr. pers.',
    'pr. poss.',
    'pr. rel. inv.',
    'prép.',
    'prép. et adv.',
    'symb.'
  ].freeze

  SEPARATOR = ';'

  # InternshipOfferKeywords stores all uniq keywords from internship offer
  # https://www.postgresql.org/docs/current/pgtrgm.html
  # - it's computed via SyncInternshipOfferKeywordsJob
  #   this dict is setup to ignore : email, url, host, file, uint, url_path, sfloat, float, numword, numhword, version;
  #   otherwise it keeps all words, with accents (for nice prompt/search)
  # - it's searchable with pg_trgm for typo tolearant search (we are speaking to Freshman)
  # - it's curated via ActiveAdmin [searchable]
  scope :search, lambda { |term|
    quoted_term = ActiveRecord::Base.connection.quote_string(term)
    where('word % :term', term: term)
      .where(searchable: true)
      .order(Arel.sql("similarity(word, '#{quoted_term}') DESC"))
  }

  def self.search_word_qualification
    where('word_nature is null')
      .where(searchable: true)
      .find_each(batch_size: 100) do |keyword|
      qualify_single_word(keyword: keyword)
    end
  end

  def self.qualify_single_word(keyword:)
    if keyword.word.length <= 2
      make_unsearchable(id: keyword.id)
    else
      natures = Services::SyncFrenchDictionnary.new(word: keyword.word)
                                               .natures
                                               .sort
                                               .join(SEPARATOR)
                                               .truncate(199)

      if natures == '' || all_rejected_natures?(natures: natures)
        update_keyword(id: keyword.id, natures: natures, searchable: false)
      else
        update_keyword(id: keyword.id, natures: natures, searchable: true)
      end
    end
  end

  def self.make_unsearchable(id:)
    InternshipOfferKeyword.where(id: id)
                          .update(searchable: false)
  end

  def self.update_keyword(id:, natures:, searchable:)
    InternshipOfferKeyword.where(id: id)
                          .update(
                            word_nature: natures,
                            searchable: searchable
                          )
  end

  def self.all_rejected_natures?(natures:)
    natures.split(SEPARATOR)
           .difference(REJECTED_NATURES)
           .empty?
  end

  rails_admin do
    weight 14
    navigation_label 'Divers'
  end
end
