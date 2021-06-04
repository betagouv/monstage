module EmailWhitelists
  class Ministry < EmailWhitelist
    rails_admin do
      list do
        field :id
        field :email
      end
      show do
        field :id
        field :email
      end
      edit do
        field :email
      end
    end

    protected

    def notify_account_ready
      StatisticianEmailWhitelistMailer.notify_ready(recipient_email: email)
                                      .deliver_later
    end
  end
end