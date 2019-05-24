# frozen_string_literal: true

class CreateSchoolInternshipWeeks < ActiveRecord::Migration[5.2]
  def change
    create_table :school_internship_weeks do |t|
      t.belongs_to :school, foreign_key: true
      t.belongs_to :week, foreign_key: true

      t.timestamps
    end
  end
end
