class AddContactPhoneToPracticalInfo < ActiveRecord::Migration[7.0]
  def change
    add_column :practical_infos, :contact_phone, :string, limit: 20, null: true
    add_column :internship_offers, :contact_phone, :string, limit: 20, null: true
  end
end
