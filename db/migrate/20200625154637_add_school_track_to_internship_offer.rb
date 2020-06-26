class AddSchoolTrackToInternshipOffer < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE internship_offer_school_track AS ENUM('troisieme_generale','troisieme_prep_pro','troisieme_segpa','bac_pro');
    SQL
    add_column :internship_offers, :school_track, :internship_offer_school_track
    InternshipOffer.update_all(school_track: :troisieme_generale)
  end

  def down
    remove_column :internship_offers, :school_track
    execute <<-SQL
      DROP TYPE internship_offer_school_track;
    SQL
  end
end
