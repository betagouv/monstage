class AddAcceptTermsToUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :accept_terms, :boolean, null: false, default: false
    User.update_all(accept_terms: true)
  end

  def down
    remove_column :users, :accept_terms
  end
end
