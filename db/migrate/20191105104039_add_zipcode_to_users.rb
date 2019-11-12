class PrefillInternshipOfferWeeksCount < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :zipcode, :string
  end
end
