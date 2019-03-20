class AddAasmStateToInternshipApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_applications, :aasm_state, :string
  end
end
