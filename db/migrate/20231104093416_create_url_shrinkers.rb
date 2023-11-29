class CreateUrlShrinkers < ActiveRecord::Migration[7.0]
  def change
    create_table :url_shrinkers do |t|
      t.string :original_url
      t.string :url_token
      t.integer :click_count, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
