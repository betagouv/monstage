class CreateOperatorsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :operators do |t|
      t.string :name
    end
    create_table :internship_offer_operators do |t|
      t.belongs_to :internship_offer, foreign_key: true
      t.belongs_to :operator, foreign_key: true
      t.timestamps
    end
  end
end
