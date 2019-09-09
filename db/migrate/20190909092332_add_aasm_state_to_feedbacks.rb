class AddAasmStateToFeedbacks < ActiveRecord::Migration[6.0]
  def change
    add_column :feedbacks, :aasm_state, :string
  end
end
