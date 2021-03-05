class AddSchoolTypeToInternshipOffer < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE internship_offer_school_type AS ENUM ('middle_school', 'high_school');
    SQL
    add_column :internship_offers, :school_type, :internship_offer_school_type
    InternshipOffer.update_all(school_type: :middle_school)
  end

  def down
    remove_column :internship_offers, :school_type
    execute <<-SQL
      DROP TYPE internship_offer_school_type;
    SQL
  end
end
