# frozen_string_literal: true

class AddHasParentalConsentToStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :has_parental_consent, :boolean, default: false
  end
end
