class RenameStartDateAndRemoveEndDateFromInternshipAgreements < ActiveRecord::Migration[6.0]
  def change
    remove_column :internship_agreements, :end_date
    rename_column :internship_agreements, :start_date, :date_range
    change_column :internship_agreements, :date_range, :string, null: false
  end
end
