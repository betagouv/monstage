class AddAgreementSignatorableColumnToUser < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :agreement_signatorable, :boolean, default: false
  end

  def down
    remove_column :users, :agreement_signatorable
  end
end
