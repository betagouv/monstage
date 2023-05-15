# frozen_string_literal: true

module Users
  class EducationStatistician < User
    include Signatorable
    include Statisticianable
    include StatisticianDepartmentable

    has_one :email_whitelist,
            class_name: 'EmailWhitelists::EducationStatistician',
            foreign_key: :user_id,
            dependent: :destroy

    METABASE_DASHBOARD_ID = 8

    def education_statistician? ; true end

    def presenter
      Presenters::PrefectureStatistician.new(self)
    end

    rails_admin do
      list do
        field :department do
          label 'Département'
          pretty_value { bindings[:object]&.department}
        end
        field :department_zipcode do
          label 'Code postal'
          pretty_value { bindings[:object]&.department_zipcode}
        end
      end
      
      export do
        field :department, :string do
          export_value do
            bindings[:object]&.department
          end
        end
        field :zipcode, :string do
          export_value do
            bindings[:object]&.department_zipcode
          end
        end
      end
    end

    private

    # on create, make sure to assign existing email whitelist
    # EmailWhitelists::EducationStatistician holds the user_id foreign key
    def assign_email_whitelist_and_confirm
      self.email_whitelist = EmailWhitelists::EducationStatistician.find_by(email: email)
      self.confirmed_at = Time.now
    end

    def email_in_list
      unless EmailWhitelists::EducationStatistician.exists?(email: email)
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
