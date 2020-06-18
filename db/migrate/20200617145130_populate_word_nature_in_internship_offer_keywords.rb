# frozen_string_literal: true

class PopulateWordNatureInInternshipOfferKeywords < ActiveRecord::Migration[6.0]
  REJECTED_NATURES = [
    'adj. poss.',
    'adv.',
    'adv. de manière',
    'article défini',
    'articles',
    'conj. de coord',
    'conj. de sub.',
    'pr. adverbial',
    'pr. interr.',
    'pr. pers.',
    'pr. poss.',
    'pr. rel. inv.',
    'prép.',
    'symb.'
  ].freeze
  SEPARATOR = ';'

  def up
    # to clean when finished
    counter = 0

    InternshipOfferKeyword.where('word_nature is null')
                          .find_each(batch_size: 100) do |keyword|
      if keyword.word.length <= 2
        make_unsearchable(id: keyword.id)
      else
        natures = Services::SyncDictionnary.new(word: keyword.word)
                                           .natures
                                           .sort
                                           .join(SEPARATOR)
                                           .truncate(199)

        if natures == '' || all_rejected_natures?(natures: natures)
          update_keyword(id: keyword.id, natures: '', searchable: false)
          say "----  #{keyword.word} : #{natures}  ----"
        else
          update_keyword(id: keyword.id, natures: natures, searchable: true)
          say "++++  #{keyword.word} : #{natures}  ++++"
        end
      end

      # next lines to disappear when finished
      sleep(rand(50).to_f / 100)
      counter += 1
      break if counter > 150
    end
  end

  def down
    # InternshipOfferKeyword.where('word_nature is not null')
    #                       .update_all(word_nature: nil)
  end

  def make_unsearchable(id:)
    InternshipOfferKeyword.where(id: id)
                          .update(searchable: false)
  end

  def update_keyword(id:, natures:, searchable:)
      InternshipOfferKeyword.where(id: id)
                            .update(
                              word_nature: natures,
                              searchable: searchable
                            )
  end

  def all_rejected_natures?(natures:)
    (natures.split(SEPARATOR) - REJECTED_NATURES).empty?
  end
end
