# frozen_string_literal: true

module Users
  class MinistryStatistician < User
    include Signatorable
    include Statisticianable

    METABASE_DASHBOARD_ID = 10

    has_one :ministry_email_whitelist,
            class_name: 'EmailWhitelists::Ministry',
            foreign_key: :user_id,
            dependent: :destroy

    def ministry_email_whitelist
      EmailWhitelists::Ministry.find_by(email: email)
    end

    def ministries
      ministry_email_whitelist&.groups
    end

    def dashboard_name
      'Statistiques nationales'
    end

    def ministry_statistician? ; true end

    def presenter
      Presenters::MinistryStatistician.new(self)
    end

    def assign_email_whitelist_and_confirm
      self.ministry_email_whitelist = EmailWhitelists::Ministry.find_by(email: email)
      self.confirmed_at = Time.now
    end

    private

    def email_in_list
      if ministries&.empty? || ministry_email_whitelist.nil?
        errors.add(
          :email,
          'Votre adresse électronique n\'est pas reconnue, veuillez la ' \
          'transmettre à monstagedetroisieme@anct.gouv.fr afin que nous ' \
          'puissions la valider.')
      end
    end
  end
end
