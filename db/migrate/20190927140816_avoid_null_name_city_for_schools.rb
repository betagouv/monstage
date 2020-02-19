# frozen_string_literal: true

class AvoidNullNameCityForSchools < ActiveRecord::Migration[6.0]
  def change
    School.where(name: nil).update_all(name: '')
    School.where(city: nil).update_all(city: '')
    change_column :schools, :name, :string, null: false, default: ''
    change_column :schools, :city, :string, null: false, default: ''
  end
end
