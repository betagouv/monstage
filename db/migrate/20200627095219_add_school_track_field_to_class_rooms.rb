class AddSchoolTrackFieldToClassRooms < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE class_room_school_track AS ENUM('troisieme_generale','troisieme_prepa_metier','troisieme_segpa','bac_pro');
    SQL
    add_column :class_rooms, :school_track, :class_room_school_track
    ClassRoom.update_all(school_track: :troisieme_generale)
  end

  def down
    remove_column :class_rooms, :school_track
    execute <<-SQL
      DROP TYPE class_room_school_track;
    SQL
  end
end
