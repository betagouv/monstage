# frozen_string_literal: true

class SetupSchoolSearch < ActiveRecord::Migration[5.2]
  def up
    enable_extension 'unaccent'

    add_timestamps(:schools, default: Time.zone.now)
    change_column_default :schools, :created_at, nil
    change_column_default :schools, :updated_at, nil

    add_column :schools, :city_tsv, :tsvector
    add_index :schools, :city_tsv, using: 'gin'

    now = Time.current.to_s(:db)
  end

  def down
    remove_index :schools, :city_tsv
    remove_column :schools, :city_tsv
    remove_timestamps(:schools)
    disable_extension 'unaccent'
  end
end
