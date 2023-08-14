class CreateAreaNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :area_notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :internship_offer_area, null: false, foreign_key: true
      t.boolean :notify, default: true

      t.timestamps
    end

    add_index :area_notifications, [:user_id, :internship_offer_area_id], unique: true, name: 'index_area_notifications_on_user_and_area'
  end
end
