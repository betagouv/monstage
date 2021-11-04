class CreateMonthsTable < ActiveRecord::Migration[6.1]
  def change
    create_table(:months, {id: false, primary_key: :date}) do |t|
      t.date :date

      t.timestamps
    end
  end
end
