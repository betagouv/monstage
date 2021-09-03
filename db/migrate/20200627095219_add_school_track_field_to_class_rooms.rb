class AddSchoolTrackFieldToClassRooms < ActiveRecord::Migration[6.0]
  def up
    # Bac_pro school_track are given up on Sept. third 2021
    execute <<-SQL
      CREATE TYPE class_room_school_track AS ENUM('troisieme_generale','troisieme_prepa_metier','troisieme_segpa','bac_pro');
    SQL
    add_column :class_rooms, :school_track, :class_room_school_track, null: false, default: 'troisieme_generale'
  end

  def down
    remove_column :class_rooms, :school_track
    execute <<-SQL
      DROP TYPE class_room_school_track;
    SQL
  end
end
