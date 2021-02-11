class AddSchoolDelegationToSignDeliveredAtToInternshipAgreements < ActiveRecord::Migration[6.1]
  def change
    add_column :internship_agreements, :school_delegation_to_sign_delivered_at, :date
  end
end
