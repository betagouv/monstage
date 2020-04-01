class CreateKeywordTextSearchConfiguration < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TEXT SEARCH DICTIONARY public.dict_search_with_synonoym (
        TEMPLATE = thesaurus,
        DictFile = thesaurus_monstage,
        Dictionary = pg_catalog.french_stem
      );
    SQL
    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION public.config_search_with_synonym (COPY = simple);
    SQL

    execute <<-SQL
      ALTER TEXT SEARCH CONFIGURATION public.config_search_with_synonym
        ALTER MAPPING FOR asciiword
          WITH public.dict_search_with_synonoym, dict_internship_offer_keywords;
    SQL
  end

  def down
    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION public.config_search_with_synonym
    SQL

    execute <<-SQL
      DROP TEXT SEARCH DICTIONARY IF EXISTS public.dict_search_with_synonoym
    SQL
  end
end
