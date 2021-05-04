class CreatePartners < ActiveRecord::Migration[6.1]
  def change
    create_table :partners do |t|
      t.string :name, null: false
      t.integer :target_count, default: 0
      t.string :logo
      t.string :website

      t.timestamps
    end
  end
end
