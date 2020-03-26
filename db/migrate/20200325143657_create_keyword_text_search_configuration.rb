class CreateKeywordTextSearchConfiguration < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TEXT SEARCH DICTIONARY public.french_simple_dict (
        TEMPLATE = pg_catalog.simple
      , STOPWORDS = french
      );
    SQL
    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION public.french_simple (COPY = simple);
    SQL

    execute <<-SQL
      ALTER  TEXT SEARCH CONFIGURATION public.french_simple
        ALTER MAPPING FOR asciiword WITH public.french_simple_dict;
    SQL
  end

  def down
    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION public.french_simple
    SQL

    execute <<-SQL
      DROP TEXT SEARCH DICTIONARY IF EXISTS public.french_simple_dict
    SQL
  end
end
