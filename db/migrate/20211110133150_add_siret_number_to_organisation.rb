class AddSiretNumberToOrganisation < ActiveRecord::Migration[6.1]
  def up
    change_column :organisations, :employer_id, :integer, null: true
  end

  def down
  end
end
