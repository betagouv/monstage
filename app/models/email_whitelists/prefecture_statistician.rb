module EmailWhitelists
  class PrefectureStatistician < EmailWhitelist
    validates :zipcode, inclusion: { in: Department::MAP.keys }
    rails_admin do
      weight 9
      navigation_label "Listes blanches"

      list do
        field :id
        field :email
        field :zipcode
      end
      show do
        field :id
        field :email
        field :zipcode
      end
      edit do
        field :email
        field :zipcode
      end
    end

    protected

    def notify_account_ready
      StatisticianEmailWhitelistMailer.notify_ready(recipient_email: email)
                                      .deliver_later
    end
  end
end