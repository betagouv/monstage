class CreateUsersSearchHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :users_search_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :keywords, limit: 255
      t.float :latitude
      t.float :longitude
      t.string :city
      t.integer :radius
      t.integer :results_count, default: 0

      t.timestamps
    end
  end
end
