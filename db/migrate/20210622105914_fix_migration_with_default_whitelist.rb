class FixMigrationWithDefaultWhitelist < ActiveRecord::Migration[6.1]
  def up
    EmailWhitelist.where(type: 'EmailWhitelist::Statistician').update_all(type: 'EmailWhitelists::PrefectureStatistician')
    EmailWhitelist.where(type: 'EmailWhitelist::Ministry').update_all(type: 'EmailWhitelists::Ministry')

    change_column_default :email_whitelists, :type, from: 'EmailWhitelist::Statistician', to:  'EmailWhitelists::PrefectureStatistician'
  end

  def down
  end
end
