class RenameGroupNameInGroup < ActiveRecord::Migration[5.2]
  def change
    rename_column :internship_offers, :group_name, :group
  end
end
