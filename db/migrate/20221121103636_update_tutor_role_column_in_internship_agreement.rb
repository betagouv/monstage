class UpdateTutorRoleColumnInInternshipAgreement < ActiveRecord::Migration[7.0]
  def up
    change_column :internship_agreements, :tutor_role, :string, limit: 150, null: true
  end

  def down
    change_column :internship_agreements, :tutor_role, :string, limit: 100, null: true
  end
end
