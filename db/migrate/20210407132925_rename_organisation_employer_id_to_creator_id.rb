class RenameOrganisationEmployerIdToCreatorId < ActiveRecord::Migration[6.1]
  def change
    rename_column :organisations, :employer_id, :creator_id
  end
end
