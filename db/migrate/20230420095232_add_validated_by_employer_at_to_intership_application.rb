class AddValidatedByEmployerAtToIntershipApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :internship_applications, :validated_by_employer_at, :datetime, null: true
  end
end