class AddSchoolTrackToInternshipOffer < ActiveRecord::Migration[6.0]
  def up
    add_column :internship_offers, :school_track, :class_room_school_track, null: false, default: 'troisieme_generale'
  end

  def down
    remove_column :internship_offers, :school_track
  end
end
