class UpdateSchoolTrackTroisiemePrepaMetierClassRoom < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      ALTER TYPE class_room_school_track RENAME VALUE 'troisieme_prepa_metier' TO 'troisieme_prepa_metiers';
    SQL
  end

  def down
    execute <<-SQL
      ALTER TYPE class_room_school_track RENAME VALUE 'troisieme_prepa_metiers' TO 'troisieme_prepa_metier';
    SQL
  end
end
