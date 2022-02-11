class AddWeekToInternshipApplication < ActiveRecord::Migration[6.1]
  def change
    add_reference :internship_applications, :week, index: true, foreign_key: true, optional: true
  end
end
