class AddTutorRoleToInternshipOffers < ActiveRecord::Migration[7.0]
  def up
    add_column :internship_offers, :tutor_role, :string, limit: 70
  end

  def down
    remove_column :internship_offers, :tutor_role
  end
end
