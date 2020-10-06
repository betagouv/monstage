class RenameTableMentor < ActiveRecord::Migration[6.0]
  def change
    rename_table :mentors, :tutors
  end
end
