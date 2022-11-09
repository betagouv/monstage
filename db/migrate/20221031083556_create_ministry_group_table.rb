class CreateMinistryGroupTable < ActiveRecord::Migration[7.0]
  def up
    create_table :ministry_groups do |t|
      t.belongs_to :group
      t.belongs_to :email_whitelist

      t.timestamps
    end

  end

  def down
    remove_column :groups, :ministry_group_id if column_exists?(:groups, :ministry_group_id)

    drop_table :ministry_groups
  end
end
