module EmailWhitelists
  class PrefectureStatistician < EmailWhitelist
    validates :zipcode, inclusion: { in: Department::MAP.keys }

    protected

    def notify_account_ready
      StatisticianEmailWhitelistMailer.notify_ready(recipient_email: email)
                                      .deliver_later
    end
  end
end