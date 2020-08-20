# frozen_string_literal: true

class InternshipOfferKeyword < ApplicationRecord
  include PgSearch::Model

  MAX_SYNONYM_COUNT = 6
  REJECTED_NATURES = [
    'adj. poss.',
    'adj. numér. cardinal',
    'adj. dém.',
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
  THESAURUS_FILE_PATH = 'db/tsearch_data/thesaurus_monstage.ths'
  SEPARATOR = ';'
  STOP_WORDS = %w[ au aux avec ce ces dans de des du elle en et eux il je la le leur lui ma mais me même mes moi mon ne nos notre nous on ou par pas pour qu que qui sa se ses son sur ta te tes toi ton tu un une vos votre vous c d j l à m n s t y été étée étées étés étant étante étants étantes suis es est sommes êtes sont serai seras sera serons serez seront serais serait serions seriez seraient étais était étions étiez étaient fus fut fûmes fûtes furent sois soit soyons soyez soient fusse fusses fût fussions fussiez fussent ayant ayante ayantes ayants eu eue eues eus ai as avons avez ont aurai auras aura aurons aurez auront aurais aurait aurions auriez auraient avais avait avions aviez avaient eut eûmes eûtes eurent aie aies ait ayons ayez aient eusse eusses eût eussions eussiez eussent aurion mien mienne tienne sienne tiens les ca cette cet celui celle ceux soi donc or ni car quoi dont quelle laquelle lesquels lequel si blog site a meme sous etant etes sears etais etait etiez etaient fumes futes ].freeze

  # InternshipOfferKeywords stores all uniq keywords from internship offer
  # https://www.postgresql.org/docs/current/pgtrgm.html
  # - it's computed via SyncInternshipOfferKeywordsJob
  #   this dict is setup to ignore : email, url, host, file, uint, url_path, sfloat, float, numword, numhword, version;
  #   otherwise it keeps all words, with accents (for nice prompt/search)
  # - it's searchable with pg_trgm for typo tolearant search (we are speaking to Freshmen)
  # - it's curated via ActiveAdmin [searchable]
  scope :search, lambda { |term|
    quoted_term = ActiveRecord::Base.connection.quote_string(term)
    where('word % :term', term: term)
      .where(searchable: true)
      .order(Arel.sql("similarity(word, '#{quoted_term}') DESC"))
  }

  class << self
    def search_word_qualification
      where('word_nature is null')
        .where(searchable: true)
        .find_each(batch_size: 100) do |keyword|
          qualify_single_word(keyword: keyword)
        end
        # update_thesaurus_file TODO
    end

    # new keywords are
    # - searchable by default
    # and their
    # - word_nature is null by default (word nature example : 'v.tr; prép.')

    # This methods aims at providing both searchability and synonyms
    def qualify_single_word(keyword:)
      synonyms = []
      natures = []
      searchable = keyword.word.length >= 3
      if searchable
        natures = Services::SyncFrenchDictionnary.new(word: keyword.word)
                                                 .natures
                                                 .sort
        searchable = searchable?(keyword: keyword, natures: natures)
        if searchable
          # synonyms = Services::SyncCnrtlSynonym.new(word: keyword.word)
          #                                      .synonyms[0..MAX_SYNONYM_COUNT]
        end
      end
      InternshipOfferKeyword.where(id: keyword.id)
                            .update(
                              word_nature: total_length_limited(words: natures, length: 199),
                              searchable: searchable,
                              synonyms: total_length_limited(words: synonyms, length: 199)
                            )
    end

    def update_thesaurus_file
      CSV.open(THESAURUS_FILE_PATH, "wb" ) do |csv|
        InternshipOfferKeyword.where(searchable: true)
                              .where.not('synonyms = ?', '')
                              .each do |keyword|
                                make_thesaurus_lines(keyword: keyword, csv: csv)
                              end
      end
    end

    private

    def searchable?(keyword:, natures:)
      any_accepted_nature?(natures: natures) &&
      !stop_word?(keyword: keyword)
    end

    def total_length_limited(words:, length:) # TODO
      words_joined = ''
      words.each do |word|
        words_so_far = words_joined
        words_joined = "#{words_joined}#{SEPARATOR}#{word}"
        return words_so_far[1..-1] if words_joined.length >= length
      end
      words_joined[1..-1]
    end

    def any_accepted_nature?(natures:)
      natures.difference(REJECTED_NATURES)
             .count
             .positive?
    end

    def stop_word?(keyword:)
      STOP_WORDS.include?(keyword.word)
    end

    def make_thesaurus_lines(keyword:, csv:)
      keyword.synonyms.split(';').each do |syn|
        cleaned_synonynms = stop_word_cleaned(synonyms: syn)
        csv << ["#{cleaned_synonynms} : #{keyword.word}"] unless cleaned_synonynms.match(/\A\s*\?\s*\z/)
      end
      csv
    end

    def stop_word_cleaned(synonyms:)
      synonyms.gsub(/\b(\w{2})\b/, '?')
              .gsub(/\b(#{STOP_WORDS.join('|')}})\b/i, '?')

    end
  end
end
