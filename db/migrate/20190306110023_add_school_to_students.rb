# frozen_string_literal: true

class AddSchoolToStudents < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :school
  end
end
