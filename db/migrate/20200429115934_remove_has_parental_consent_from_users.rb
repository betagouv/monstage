class RemoveHasParentalConsentFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :has_parental_consent
  end
end
