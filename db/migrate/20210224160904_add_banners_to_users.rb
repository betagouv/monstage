class AddBannersToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :banners, :jsonb, default: {  }
  end
end
