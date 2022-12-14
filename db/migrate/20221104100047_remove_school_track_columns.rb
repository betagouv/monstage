class RemoveSchoolTrackColumns < ActiveRecord::Migration[7.0]
  def up
    remove_column :internship_offers, :school_track
    remove_column :internship_offer_infos, :school_track
    remove_column :class_rooms, :school_track
    remove_column :internship_agreements, :school_track
    
    execute "DROP TYPE IF EXISTS class_room_school_track"
  end


  def down
    add_column :internship_offers, :school_track, :string, null: false, default: 'troisieme_generale'
    add_column :internship_offer_infos, :school_track, :string, null: false, default: 'troisieme_generale'
    add_column :internship_agreements, :school_track, :string, null: false,  default: 'troisieme_generale'
    add_column :class_rooms, :school_track, :string, null: false, default: 'troisieme_generale'
  end
 
end
