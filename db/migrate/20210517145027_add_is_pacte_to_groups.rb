class AddIsPacteToGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :groups, :is_paqte, :boolean
    Group.where(is_public: true).update_all(is_paqte: false)
    Group.where(is_public: false).update_all(is_paqte: true)
  end
end
