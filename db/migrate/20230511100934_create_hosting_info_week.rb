class CreateHostingInfoWeek < ActiveRecord::Migration[7.0]
  def change
    create_table :hosting_info_weeks do |t|
      t.belongs_to :hosting_info, foreign_key: true
      t.belongs_to :week, foreign_key: true
      t.integer :total_applications_count, null: false, default: 0
      
      t.timestamps
    end
  end
end
