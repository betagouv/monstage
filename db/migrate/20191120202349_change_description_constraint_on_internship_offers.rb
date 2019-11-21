class ChangeDescriptionConstraintOnInternshipOffers < ActiveRecord::Migration[6.0]
  def up
    InternshipOffer.all.each do |io|
      io.description_rich_text = (io.attributes["description"] || "desc").truncate(BaseInternshipOffer::DESCRIPTION_MAX_CHAR_COUNT)
      io.employer_description_rich_text = (io.attributes["employer_description"] || "").truncate(BaseInternshipOffer::EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT)
      io.save!
    end
  end

  def down
  end
end
