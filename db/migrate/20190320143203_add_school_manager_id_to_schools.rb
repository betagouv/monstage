class AddSchoolManagerIdToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :school_manager_id, :bigint
    add_foreign_key :schools, :users, column: :school_manager_id, primary_key: :id
  end
end
