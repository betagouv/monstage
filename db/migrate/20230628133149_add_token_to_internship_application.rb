class AddTokenToInternshipApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :internship_applications, :token, :string
  end
end
