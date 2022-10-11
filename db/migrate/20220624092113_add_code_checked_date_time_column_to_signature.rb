class AddCodeCheckedDateTimeColumnToSignature < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :signature_phone_token_checked_at, :datetime, after: :signature_phone_token, null: true
  end
  def down
    remove_column :users, :signature_phone_token_checked_at
  end
end
