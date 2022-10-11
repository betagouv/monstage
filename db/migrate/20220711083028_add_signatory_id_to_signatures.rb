class AddSignatoryIdToSignatures < ActiveRecord::Migration[7.0]
  def up
    add_reference :signatures, :user, index: true
  end

  def down
    remove_reference :signatures, :user
  end
end
