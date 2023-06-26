class AddAasmStateToTeamMember < ActiveRecord::Migration[7.0]
  def change
    add_column :team_members, :aasm_state, :string, default: 'pending_invitation'
  end
end
