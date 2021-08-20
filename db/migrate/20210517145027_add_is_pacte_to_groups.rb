class AddIsPacteToGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :groups, :is_pacte, :boolean
    Group.where(is_public: true).update_all(is_pacte: false)
    Group.where(is_public: false).update_all(is_pacte: true)
  end
end
