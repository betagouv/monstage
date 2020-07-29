class RemoveInternshipOffersSchoolType < ActiveRecord::Migration[6.0]
  def up
    remove_column :internship_offers, :school_type
    execute <<-SQL
      DROP TYPE internship_offer_school_type;
    SQL
    InternshipOffer.update_all(type: InternshipOffers::WeeklyFramed.name)
  end

  def down
    execute <<-SQL
      CREATE TYPE internship_offer_school_type AS ENUM ('middle_school', 'high_school');
    SQL
    add_column :internship_offers, :school_type, :internship_offer_school_type
  end
end
