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
  end

  def down
    execute <<-SQL
      DROP index internship_offer_keywords_trgm
    SQL
    drop_table :internship_offer_keywords
  end
end
