class AddDiscardedAtToInternshipAgreements < ActiveRecord::Migration[7.0]
  def change
    add_column :internship_agreements, :discarded_at, :datetime
    add_index :internship_agreements, :discarded_at
  end
end
