class FixCreateKeywordTextSearchConfiguration < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION public.config_search_with_synonym;
    SQL
    # There was a typo here : dict_search_with_synonoym
    execute <<-SQL
      DROP TEXT SEARCH DICTIONARY IF EXISTS public.dict_search_with_synonoym;
    SQL

    execute <<-SQL
        CREATE TEXT SEARCH DICTIONARY public.dict_search_with_synonym (
          TEMPLATE = thesaurus,
          DictFile = thesaurus_monstage,
          Dictionary = french_stem
        );
    SQL

    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION public.config_search_with_synonym (COPY = simple);
    SQL

    execute <<-SQL
      ALTER TEXT SEARCH CONFIGURATION public.config_search_with_synonym
        ALTER MAPPING FOR asciiword, asciihword, hword_asciipart, word, hword, hword_part
          WITH public.dict_search_with_synonym, unaccent, pg_catalog.french_stem;
    SQL

    execute <<-SQL
      ALTER TEXT SEARCH CONFIGURATION public.config_search_with_synonym
        DROP MAPPING FOR email, url, host, file, uint, url_path, sfloat, float, numword, numhword, version;
    SQL
  end

  def down
    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION public.config_search_with_synonym;
    SQL

    execute <<-SQL
      DROP TEXT SEARCH DICTIONARY IF EXISTS public.dict_search_with_synonym;
    SQL

    execute <<-SQL
      CREATE TEXT SEARCH DICTIONARY public.dict_search_with_synonoym (
        TEMPLATE = thesaurus,
        DictFile = thesaurus_monstage,
        Dictionary = french_stem
      );
    SQL

    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION public.config_search_with_synonym (COPY = simple);
    SQL

    execute <<-SQL
      ALTER TEXT SEARCH CONFIGURATION public.config_search_with_synonym
        ALTER MAPPING FOR asciiword, asciihword, hword_asciipart, word, hword, hword_part
          WITH public.dict_search_with_synonoym, unaccent, pg_catalog.french_stem;
    SQL
    execute <<-SQL
      ALTER TEXT SEARCH CONFIGURATION public.config_search_with_synonym
        DROP MAPPING FOR email, url, host, file, uint, url_path, sfloat, float, numword, numhword, version;
    SQL
  end
end

