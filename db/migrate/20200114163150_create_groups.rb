class CreateGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.boolean :is_public
      t.string :name

      t.timestamps
    end
  end
end
