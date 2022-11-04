class RemoveSchoolTrackColumns < ActiveRecord::Migration[7.0]
  def up
    remove_column :internship_offers, :school_track
    remove_column :internship_offer_infos, :school_track
    remove_column :class_rooms, :school_track
    remove_column :internship_agreements, :school_track
    
    execute <<-SQL
      DROP TYPE class_room_school_track;
    SQL
  end


  def down
    execute <<-SQL
      CREATE TYPE class_room_school_track AS ENUM('troisieme_generale','troisieme_prepa_metiers','troisieme_segpa','bac_pro');
    SQL
    
    add_column :internship_offers, :school_track, :class_room_school_track, null: false, default: 'troisieme_generale'
    add_column :internship_offer_infos, :school_track, :class_room_school_track, null: false, default: 'troisieme_generale'
    add_column :internship_agreements, :school_track, :class_room_school_track, null: false,  default: 'troisieme_generale'
    add_column :class_rooms, :school_track, :class_room_school_track, null: false, default: 'troisieme_generale'
  end
 
end
