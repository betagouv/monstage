class AddUniqueIndexNumberYearToWeeks < ActiveRecord::Migration[5.2]
  def change
    add_index :weeks, [:number, :year], unique: true
  end
end
