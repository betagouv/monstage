class AddReadAtAdExaminedAtFieldsToInternshipApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :internship_applications, :read_at, :datetime
    add_column :internship_applications, :examined_at, :datetime
  end
end
