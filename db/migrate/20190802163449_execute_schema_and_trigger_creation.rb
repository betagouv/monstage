class ExecuteSchemaAndTriggerCreation < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      DROP TRIGGER IF EXISTS sync_schools_city_tsv
      ON schools
    SQL

    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION IF EXISTS fr
    SQL

    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION fr ( COPY = french );
      ALTER TEXT SEARCH CONFIGURATION fr
      ALTER MAPPING FOR hword, hword_part, word
      WITH unaccent, french_stem;
    SQL

    execute <<-SQL
      CREATE TRIGGER sync_schools_city_tsv BEFORE INSERT OR UPDATE
        ON schools FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger(city_tsv, 'public.fr', city);
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
      DROP TEXT SEARCH CONFIGURATION IF EXISTS fr
    SQL
  end
end
