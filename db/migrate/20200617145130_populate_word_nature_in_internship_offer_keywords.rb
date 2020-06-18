# frozen_string_literal: true

class PopulateWordNatureInInternshipOfferKeywords < ActiveRecord::Migration[6.0]
  def up
    InternshipOfferKeyword.qualify_words
  end

  def down
    InternshipOfferKeyword.where('word_nature is not null')
                          .update_all(word_nature: nil)
  end
end
