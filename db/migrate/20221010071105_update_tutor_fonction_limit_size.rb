class UpdateTutorFonctionLimitSize < ActiveRecord::Migration[7.0]
  def up
    change_column :tutors, :tutor_role, :string, limit: nil, null: true
  end

  def down
    change_column :tutors, :tutor_role, :string, limit: 70, null: false
  end
end
