class CreateOrganisations < ActiveRecord::Migration[6.0]
  def change
    create_table :organisations do |t|
      t.string :name, null: false
      t.string :street, null: false
      t.string :zipcode, null: false
      t.string :city, null: false
      t.string :website
      t.text :description
      t.st_point :coordinates, geographic: true
      t.index :coordinates, using: :gist
      t.string :department, null: false, default: ''
      # t.string :region, null: false, default: ''
      # t.string :academy, null: false, default: ''
      t.boolean :is_public, null: false, default: false
      t.belongs_to :group

      t.timestamps
    end
  end
end
