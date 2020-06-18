class PopulateWordNatureInInternshipOfferKeywords < ActiveRecord::Migration[6.0]
  def up
    counter = 0
    separator = ';'

    InternshipOfferKeyword.where('word_nature is null')
                          .find_each(batch_size: 10) do |keyword|

      natures = Services::SyncDictionnary.new(word: keyword.word)
                                         .natures
                                         .sort
                                         .join(separator)
                                         .truncate(199)

      InternshipOfferKeyword.where(id: keyword.id)
                            .update(word_nature: natures)

      # next lines to disappear when finished
      say "=====  #{keyword.word} : #{natures}  ===="
      sleep(rand(50).to_f / 100)
      counter += 1
      break if counter > 150
    end
  end

  def down
    InternshipOfferKeyword.where('word_nature is not null')
                          .update_all(word_nature: nil)
  end
end
