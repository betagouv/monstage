# frozen_string_literal: true

class CreateInternshipApplication < ActiveRecord::Migration[5.2]
  def change
    create_table :internship_applications do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :internship_offer_week, foreign_key: true

      t.text :motivation

      t.timestamps
    end
  end
end
