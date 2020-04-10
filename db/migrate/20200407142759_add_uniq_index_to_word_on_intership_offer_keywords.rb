class AddUniqIndexToWordOnIntershipOfferKeywords < ActiveRecord::Migration[6.0]
  def change
    add_index :internship_offer_keywords, :word, unique: true
    SyncInternshipOfferKeywordsJob.perform_now
  end
end
