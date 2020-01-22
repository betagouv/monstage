class ReworkPostgresTextSearchConfiguration < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TEXT SEARCH DICTIONARY public.french_nostopwords (
        Template = snowball,
        Language = french
      );
    SQL
    execute <<-SQL
      ALTER TEXT SEARCH DICTIONARY public.french_nostopwords (
        language = french,
        StopWords
      );
    SQL

    execute <<-SQL
      ALTER TEXT SEARCH CONFIGURATION public.fr
        ALTER MAPPING REPLACE french_stem WITH public.french_nostopwords;
    SQL
  end

  def down
    execute <<-SQL
      ALTER TEXT SEARCH CONFIGURATION public.fr
        ALTER MAPPING REPLACE public.french_nostopwords WITH french_stem;
    SQL

    execute <<-SQL
      DROP TEXT SEARCH DICTIONARY IF EXISTS public.french_nostopwords
    SQL
  end
end
