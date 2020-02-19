# frozen_string_literal: true

class UpdateSchoolCityTsvTrigger < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      DROP TRIGGER IF EXISTS sync_schools_city_tsv
      ON schools
    SQL
    execute <<-SQL
      CREATE TRIGGER sync_schools_city_tsv BEFORE INSERT OR UPDATE
        ON schools FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger(city_tsv, 'public.fr', city, name);
    SQL
    now = Time.current.to_s(:db)
    update("UPDATE schools SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS sync_schools_city_tsv
      ON schools
    SQL
    execute <<-SQL
      CREATE TRIGGER sync_schools_city_tsv BEFORE INSERT OR UPDATE
        ON schools FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger(city_tsv,   'public.fr', city);
    SQL
  end
end
