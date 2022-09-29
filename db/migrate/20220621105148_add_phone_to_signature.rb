class AddPhoneToSignature < ActiveRecord::Migration[7.0]
  def up
    add_column :signatures,
               :signature_phone_number,
               :string,
               limit: 20,
               after: :signature_phone_token_validity,
               null: false
  end

  def down
    remove_column :signatures, :signature_phone_number
  end
end
