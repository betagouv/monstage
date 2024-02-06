# frozen_string_literal: true

module Users
  class PrefectureStatistician < Statistician
    include StatisticianDepartmentable

    METABASE_DASHBOARD_ID = 3

    def department_statistician?; true end

    def presenter
      Presenters::PrefectureStatistician.new(self)
    end

    rails_admin do
      weight 3
      navigation_label "Référents"
      list do
        field :first_name do
          label 'Prénom'
        end
        field :last_name do
          label 'Nom'
        end
        field :email do
          label 'Email'
        end
        field :department do
          label 'Département'
          pretty_value { bindings[:object]&.department}
        end
        field :statistician_validation do
          label 'Validation'
        end
      end

      edit do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
        field :department do
          label 'Département'
        end
        field :statistician_validation do
          label 'Validation'
        end
        field :agreement_signatorable do
          label 'Signataire des conventions'
          help 'Si le V est coché en vert, le signataire doit signer TOUTES les conventions'
        end
      end

      show do
        field :first_name
        field :last_name
        field :email
        field :department do
          label 'Département'
        end
        field :statistician_validation do
          label 'Validation'
        end
      end

      export do
        field :first_name do
          label 'Prénom'
        end
        field :last_name do
          label 'Nom'
        end
        field :email do
          label 'Email'
        end
        field :created_at do
          label "Date d'inscription"
          formatted_value {
            I18n.l(bindings[:object].created_at, format: '%d/%m/%Y')
          }
        end
        field :department, :string do
          label 'Département'
          export_value do
            bindings[:object]&.department
          end
        end
        field :statistician_validation do
          label 'Validation'
          export_value do
            bindings[:object].statistician_validation ? 'Validé' : 'En attente'
          end
        end
      end
    end
  end
end
