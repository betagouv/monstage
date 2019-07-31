class SetupSchoolSearch < ActiveRecord::Migration[5.2]
  def up
    enable_extension 'unaccent'

    add_timestamps(:schools, default: Time.zone.now)
    change_column_default :schools, :created_at, nil
    change_column_default :schools, :updated_at, nil

    add_column :schools, :city_tsv, :tsvector
    add_index :schools, :city_tsv, using: 'gin'

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
      DROP TRIGGER sync_schools_city_tsv
      ON schools
    SQL

    remove_index :schools, :city_tsv
    remove_column :schools, :city_tsv
    remove_timestamps(:schools)

    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION IF EXISTS fr
    SQL

    disable_extension 'unaccent'
  end
end
