# frozen_string_literal: true

class SetDefaultBirthDateForStudents < ActiveRecord::Migration[5.2]
  def change
    Users::Student.where(birth_date: nil).update_all(birth_date: 14.years.ago)
  end
end
