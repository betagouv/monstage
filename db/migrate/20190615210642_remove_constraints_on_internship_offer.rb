class RemoveConstraintsOnInternshipOffer < ActiveRecord::Migration[5.2]
  def change
    change_column :internship_offers, :tutor_name, :string, null: true
    change_column :internship_offers, :tutor_phone, :string, null: true
    change_column :internship_offers, :tutor_email, :string, null: true
  end
end
