class AddTargetCountToOperators < ActiveRecord::Migration[6.1]
  def change
    add_column :operators, :target_count, :integer, default: 0
    add_column :operators, :logo, :string
    add_column :operators, :website, :string
    add_column :operators, :created_at, :datetime, null: false, default: Time.now
    add_column :operators, :updated_at, :datetime, null: false, default: Time.now
  end
end
