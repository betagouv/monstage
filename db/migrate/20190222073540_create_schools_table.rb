# frozen_string_literal: true

class CreateSchoolsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :schools do |t|
      t.string :name
      t.string :city
      t.string :departement_name
      t.string :postal_code
      t.string :code_uai
      t.st_point :coordinates, geographic: true
      t.index :coordinates, using: :gist
    end
  end
end
