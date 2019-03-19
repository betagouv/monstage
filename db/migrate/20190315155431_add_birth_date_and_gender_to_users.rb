class AddBirthDateAndGenderToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :birth_date, :date
    add_column :users, :gender, :string
  end
end
