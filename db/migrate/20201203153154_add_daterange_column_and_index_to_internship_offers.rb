class AddDaterangeColumnAndIndexToInternshipOffers < ActiveRecord::Migration[6.0]
  def up
    change_column :internship_offers, :first_date, :date, null: false
    change_column :internship_offers, :last_date, :date, null: false
    execute <<-SQL
      ALTER TABLE "internship_offers" ADD COLUMN daterange daterange GENERATED ALWAYS AS (daterange(first_date, last_date)) STORED
    SQL
    add_index :internship_offers, :daterange, using: :gist
  end

  def down
    remove_index :internship_offers, :daterange
    execute <<-SQL
      ALTER TABLE "internship_offers" DROP "daterange"
    SQL
    change_column :internship_offers, :last_date, :date, null: true
    change_column :internship_offers, :first_date, :date, null: true
  end
end
