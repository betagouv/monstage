class AddUuidToInternshipAgreement < ActiveRecord::Migration[7.1]
  def change
    add_column :internship_agreements, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_index :internship_agreements, :uuid, unique: true
  end
end
