class CreateInternshipOfferKeywords < ActiveRecord::Migration[6.0]
  def up
    enable_extension "pg_trgm"
    create_table :internship_offer_keywords do |t|
      t.text :word, null: false
      t.integer :ndoc, null: false
      t.integer :nentry, null: false
      t.boolean :searchable, default: true, null: false
    end

    execute <<-SQL
      CREATE INDEX internship_offer_keywords_trgm ON internship_offer_keywords
        USING GIN(word gin_trgm_ops);
    SQL

    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords (COPY = simple);
    SQL

    execute <<-SQL
      ALTER  TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords
        ALTER MAPPING FOR asciiword, asciihword, hword_asciipart, word, hword, hword_part
          WITH pg_catalog.french_stem;
    SQL

    execute <<-SQL
      ALTER TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords
        DROP MAPPING FOR email, url, host, file, uint, url_path, sfloat, float, numword, numhword, version;
    SQL
  end

  def down
    execute <<-SQL
      DROP index internship_offer_keywords_trgm
    SQL
    drop_table :internship_offer_keywords
    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION public.config_internship_offer_keywords
    SQL
  end
end

