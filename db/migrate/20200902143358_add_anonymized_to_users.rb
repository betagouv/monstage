class AddAnonymizedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :anonymized, :boolean, default: false, null: false
    User.where(first_name: 'NA',
               last_name: 'NA',
               phone: nil,
               current_sign_in_ip: nil,
               last_sign_in_ip: nil)
        .update_all(anonymized: true)
  end
end
