class AddTransferedAtColummnToInternshipApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :internship_applications, :transfered_at, :datetime, null: true
  end
end
