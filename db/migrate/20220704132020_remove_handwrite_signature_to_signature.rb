class RemoveHandwriteSignatureToSignature < ActiveRecord::Migration[7.0]
  def up
    remove_column :signatures, :handwrite_signature
  end

  def down
    add_column :signatures, :handwrite_signature, :jsonb, default: {}
  end
end
