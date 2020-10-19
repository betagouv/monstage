class AddInternshipAgreementsToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :internship_agreement_online, :boolean, default: false
  end
end
