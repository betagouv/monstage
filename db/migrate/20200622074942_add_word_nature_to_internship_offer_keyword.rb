class AddWordNatureToInternshipOfferKeyword < ActiveRecord::Migration[6.0]
  def up
    add_column :internship_offer_keywords,
                :word_nature,
                :string,
                limit: 200,
                null: true,
                default: nil
  end

  def down
    remove_column :internship_offer_keywords,
                  :word_nature
  end
end
