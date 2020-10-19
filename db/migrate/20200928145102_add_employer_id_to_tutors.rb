class AddEmployerIdToTutors < ActiveRecord::Migration[6.0]
  def change
    Tutor.destroy_all
    add_column :tutors, :employer_id, :bigint, null: false
    add_foreign_key :tutors, :users, column: :employer_id, primary_key: :id
  end
end
