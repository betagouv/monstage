class MigrateIntegerToBigintForeignKeys < ActiveRecord::Migration[6.0]
  def change
    change_column :internship_offers, :sector_id, :bigint
  end
end
