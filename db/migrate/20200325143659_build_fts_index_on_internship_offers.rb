class BuildFtsIndexOnInternshipOffers < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TRIGGER sync_internship_offers_tsv BEFORE INSERT OR UPDATE
        ON internship_offers FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger(search_tsv, 'public.config_search_with_synonym', title, description, employer_description);
    SQL
    now = Time.current.to_s(:db)
    update("UPDATE internship_offers SET updated_at = '#{now}'")
    if InternshipOffer.count.positive?
      execute "TRUNCATE TABLE internship_offer_keywords"
      execute "select * from ts_stat($$SELECT to_tsvector('public.config_internship_offer_keywords', CONCAT(unaccent(title), ' ', unaccent(description), ' ', unaccent(employer_description))) FROM internship_offers$$) ORDER BY ndoc DESC"
    end
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS sync_internship_offers_tsv
      ON internship_offers
    SQL
  end
end
