class CreateSchoolsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :schools_tables do |t|
      t.string :name
      t.string :city
      t.string :region
      t.string :postal_code
      t.st_point :coordinates, geographic: true
      t.index :coordinates, using: :gist
    end
  end
end
