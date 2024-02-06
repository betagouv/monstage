# frozen_string_literal: true

module Users
  class MinistryStatistician < Statistician

    METABASE_DASHBOARD_ID = 10

    has_many :user_groups,
             foreign_key: :user_id,
             inverse_of: :user
    has_many :groups,
              -> { where is_public: true },
              through: :user_groups
    has_many :organisations

    def ministries
      groups
    end

    def dashboard_name
      'Statistiques nationales'
    end

    def ministry_statistician? ; true end
    def employer_like? ; true end

    def presenter
      Presenters::MinistryStatistician.new(self)
    end

    rails_admin do
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
        field :ministeres do
          label 'Ministères'
          formatted_value{
              bindings[:object]&.groups.map(&:name).join(', ')
          }
        end
        field :statistician_validation do
          label 'Validation'
        end
      end

      edit do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
        field :groups do
          label 'Ministère'
          pretty_value do
            bindings[:object]&.groups.map(&:name)
          end
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
        field :ministeres do
          formatted_value{
              bindings[:object]&.groups.map(&:name).join(', ')
          }
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
        field :ministeres, :string do
          formatted_value{
              bindings[:object]&.groups.map(&:name).join(', ')
          }
        end
        field :statistician_validation do
          label 'Validation'
          export_value do
            bindings[:object].statistician_validation ? 'Validé' : 'En attente'
          end
        end
      end
    end

    def department_name
      ''
    end
  end
end
