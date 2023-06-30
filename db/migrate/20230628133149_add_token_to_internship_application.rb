class AddTokenToInternshipApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :internship_applications, :access_token, :string, null: true
  end
end
