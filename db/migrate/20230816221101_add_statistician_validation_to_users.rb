class AddStatisticianValidationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :statistician_validation, :boolean, default: false
  end
end
