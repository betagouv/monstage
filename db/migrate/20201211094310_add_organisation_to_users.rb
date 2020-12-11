class AddOrganisationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :organisation, index: true
  end
end
