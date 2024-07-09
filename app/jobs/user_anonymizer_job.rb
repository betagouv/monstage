class UserAnonymizerJob < ActiveJob::Base
  queue_as :default

  def perform(user_id:)
    user = User.find(user_id)
    user.anonymize(send_email: false)
  end
end
