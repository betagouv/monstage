# frozen_string_literal: true

class CreateTableSector < ActiveRecord::Migration[5.2]
  def change
    create_table :sectors do |t|
      t.string :name
    end
  end
end
