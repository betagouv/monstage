class EnsureProperDataValidationOnEmailWhitelistStatistician < ActiveRecord::Migration[6.0]
  def up
    EmailWhitelist.all.map do |email_whitelist|
      user = Users::Statistician.where(email: email_whitelist.email).first
      next if user.nil?
      user.email_whitelist=email_whitelist
      user.save
    end
  end
end
