class DeleteUsers < ActiveRecord::Migration[5.2]
  def change
    # This makes it easier to configure the new user table with Devise
    drop_table :users
  end
end
