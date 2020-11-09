class AddSchoolManagerAcceptTermsEmployerAcceptTermsToInternshipAgreements < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_agreements, :school_manager_accept_terms, :boolean, default: false
    add_column :internship_agreements, :employer_accept_terms, :boolean, default: false
  end
end
