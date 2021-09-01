class CleanupSearchWithSynonym < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION  IF EXISTS public.config_search_with_synonym;
    SQL

    execute <<-SQL
      DROP TEXT SEARCH DICTIONARY IF EXISTS public.dict_search_with_synonoym;
    SQL
    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION public.config_search_keyword (COPY = simple);
    SQL

    execute <<-SQL
      ALTER TEXT SEARCH CONFIGURATION public.config_search_keyword
        ALTER MAPPING FOR asciiword, asciihword, hword_asciipart, word, hword, hword_part
          WITH unaccent, pg_catalog.french_stem;
    SQL
    execute <<-SQL
      ALTER TEXT SEARCH CONFIGURATION public.config_search_keyword
        DROP MAPPING FOR email, url, host, file, uint, url_path, sfloat, float, numword, numhword, version;
    SQL
  end

  def down
    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION public.config_search_keyword;
    SQL

    execute <<-SQL
      DROP TEXT SEARCH DICTIONARY IF EXISTS public.dict_search_keyword;
    SQL
  end
end
