# frozen_string_literal: true

module Users
  class PrefectureStatistician < User
    include Signatorable
    include Statisticianable
    include StatisticianDepartmentable

    has_one :email_whitelist,
    class_name: 'EmailWhitelists::PrefectureStatistician',
    foreign_key: :user_id,
    dependent: :destroy

    METABASE_DASHBOARD_ID = 3

    def department_statistician?; true end

    def presenter
      Presenters::PrefectureStatistician.new(self)
    end

    def can_sign?(internship_agreement)
      true
    end

    private

    # on create, make sure to assign existing email whitelist
    # EmailWhitelists::PrefectureStatistician holds the user_id foreign key
    def assign_email_whitelist_and_confirm
      self.email_whitelist = EmailWhitelists::PrefectureStatistician.find_by(email: email)
      self.confirmed_at = Time.now
    end

    def email_in_list
      unless EmailWhitelists::PrefectureStatistician.exists?(email: email)
        errors.add(
          :email,
          'Votre adresse électronique n\'est pas reconnue, veuillez la ' \
          'transmettre à monstagedetroisieme@anct.gouv.fr afin que nous' \
          ' puissions la valider.'
        )
      end
    end
  end
end
