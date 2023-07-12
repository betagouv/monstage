class AddAreaReferenceToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :current_area_id, :integer
  end
end
