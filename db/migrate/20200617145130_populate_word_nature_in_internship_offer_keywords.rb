# frozen_string_literal: true

class PopulateWordNatureInInternshipOfferKeywords < ActiveRecord::Migration[6.0]
  def up
    # If done as commented below, this would take too much CPU from production 
    # and jeopardize the platform stability. It has to be done outside
    # this populating migration

    # InternshipOfferKeyword.search_word_qualification
  end

  def down
    InternshipOfferKeyword.where('word_nature is not null')
                          .update_all(word_nature: nil)
  end
end
