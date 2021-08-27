class UpdateTriggerInternshipOfferTsv < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      DROP TRIGGER IF EXISTS sync_internship_offers_tsv
      ON internship_offers
    SQL
    execute <<-SQL
      CREATE TRIGGER sync_internship_offers_tsv BEFORE INSERT OR UPDATE
        ON internship_offers FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger(search_tsv, 'public.config_search_keyword', title, description, employer_description);
    SQL
    now = Time.current.to_s(:db)
    update("UPDATE internship_offers SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS sync_internship_offers_tsv
      ON internship_offers
    SQL
  end
end
