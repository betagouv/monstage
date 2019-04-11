class CreateFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :feedbacks do |t|
      t.string :email, null: false
      t.text :comment, null: false

      t.timestamps
    end
  end
end
