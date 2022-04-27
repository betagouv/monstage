class CreateIdentities < ActiveRecord::Migration[6.1]
  def change
    create_table :identities do |t|
      t.belongs_to :user, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.references :school
      t.references :class_room
      t.date :birth_date
      t.string :gender, default: 'np'
      t.string :token
      t.boolean :anonymized, default: false

      t.timestamps
    end
  end
end
