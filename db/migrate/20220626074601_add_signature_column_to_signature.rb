class AddSignatureColumnToSignature < ActiveRecord::Migration[7.0]
  def up
    add_column :signatures, :handwrite_signature, :jsonb, default: {}
  end

  def down
    remove_column :signatures, :handwrite_signature
  end
end
