class AddTutorAcceptTermsToAgreement < ActiveRecord::Migration[6.1]
  def up
    add_column :internship_agreements, :tutor_accept_terms, :boolean, default: false
  end

  def down
    remove_column :internship_agreements, :tutor_accept_terms
  end
end
