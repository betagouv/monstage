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
    if InternshipOffer.count.positive?
      rs = execute("select * from ts_stat($$SELECT to_tsvector('french_simple', unaccent(title) || ' ' || unaccent('description')) FROM internship_offers$$) ORDER  BY ndoc DESC")

      InternshipOfferKeyword.insert_all(rs.to_a)
    end
  end

  def down
    execute <<-SQL
      DROP index internship_offer_keywords_trgm
    SQL
    drop_table :internship_offer_keywords
  end
end
