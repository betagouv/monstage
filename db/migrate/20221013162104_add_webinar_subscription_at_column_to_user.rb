class AddWebinarSubscriptionAtColumnToUser < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :subscribed_to_webinar_at, :datetime, null: true, default: nil
  end

  def down
    remove_column :users, :subscribed_to_webinar_at
  end
end
