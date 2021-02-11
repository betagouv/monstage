class AddSchoolTrackToInternshipAgreements < ActiveRecord::Migration[6.1]
  def change
    add_column :internship_agreements, :school_track, :class_room_school_track, null: false,  default: 'troisieme_generale'
  end
end
