class AddDunningLetterCountToInternshipApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :internship_applications, :dunning_letter_count, :integer, default: 0
  end
end
