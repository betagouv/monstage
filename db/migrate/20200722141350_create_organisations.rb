class CreateOrganisations < ActiveRecord::Migration[6.0]
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :street
      t.string :zipcode
      t.string :city
      t.string :website
      t.text :description
      t.st_point :coordinates, geographic: true
      t.index :coordinates, using: :gist
      t.boolean :is_public

      t.timestamps
    end
  end
end
