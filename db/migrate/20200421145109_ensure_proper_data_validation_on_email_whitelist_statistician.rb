class EnsureProperDataValidationOnEmailWhitelistStatistician < ActiveRecord::Migration[6.0]
  def up
    EmailWhitelist.all.map do |email_whitelist|
      user = Users::PrefectureStatistician.find_by(email: email_whitelist.email)
      next if user.nil?
      user.email_whitelist=email_whitelist
      user.save
    end
  end
end
