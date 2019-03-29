class CreateTableSector < ActiveRecord::Migration[5.2]
  def change
    create_table :sectors do |t|
      t.string :name
    end
  end
end
