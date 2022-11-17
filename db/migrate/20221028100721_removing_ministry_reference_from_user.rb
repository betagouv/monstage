class RemovingMinistryReferenceFromUser < ActiveRecord::Migration[7.0]
def up
    remove_reference :users, :ministry
  end

  def down
    add_reference :users, :ministry, foreign_key: {to_table: :groups}, null: true
  end
end
