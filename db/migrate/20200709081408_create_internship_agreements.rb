class CreateInternshipAgreements < ActiveRecord::Migration[6.0]
  def change
    create_table :internship_agreements do |t|
      t.datetime :start_date
      t.datetime  :end_date
      t.string :aasm_state

      t.belongs_to :internship_application
      t.timestamps
    end
  end
end
