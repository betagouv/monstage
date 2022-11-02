class CreateMinistryGroupTable < ActiveRecord::Migration[7.0]
  def up
    create_table :ministry_groups do |t|
      t.belongs_to :group
      t.belongs_to :email_whitelist

      t.timestamps
    end

    EmailWhitelists::Ministry.all.each do |email_whitelist|
      ministry_group = MinistryGroup.create(
        group_id: email_whitelist.group_id,
        email_whitelist_id: email_whitelist.id
      )
    end
  end

  def down
    MinistryGroup.all.each do |ministry_group|
      # with following code, group_id is set to the last occurence of a group with the same email_whitelist_id
      email_whitelist = EmailWhitelists::Ministry.find_by(id: ministry_group.email_whitelist_id)
      email_whitelist.update(group_id: ministry_group.group_id)
    end

    remove_column :groups, :ministry_group_id if column_exists?(:groups, :ministry_group_id)

    drop_table :ministry_groups
  end
end
