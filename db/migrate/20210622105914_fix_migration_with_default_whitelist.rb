class FixMigrationWithDefaultWhitelist < ActiveRecord::Migration[6.1]
  def up
    EmailWhitelist.where(type: 'EmailWhitelist::Statistician').update_all(type: 'EmailWhitelists::Statistician')
    EmailWhitelist.where(type: 'EmailWhitelist::Ministry').update_all(type: 'EmailWhitelists::Ministry')

    change_column_default :email_whitelists, :type, from: 'EmailWhitelist::Statistician', to:  'EmailWhitelists::Statistician'
  end

  def down
  end
end
