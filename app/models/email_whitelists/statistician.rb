module EmailWhitelists
  class Statistician < EmailWhitelist
    validates :zipcode,
              inclusion: { in: Department::MAP.keys },
              presence: { message: 'Le département doit être saisi ' \
                                   'avec 2 chiffres ou 3 caractères' }
    validates :email, presence: true          
    rails_admin do
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
        field :zipcode do
          label 'Departement (sur 2 ou 3 caractères)'
        end
      end
    end

    protected

    def notify_account_ready
      StatisticianEmailWhitelistMailer.notify_ready(recipient_email: email)
                                      .deliver_later
    end
  end
end