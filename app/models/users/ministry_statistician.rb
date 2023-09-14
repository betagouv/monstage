# frozen_string_literal: true

module Users
  class MinistryStatistician < Statistician
    include Signatorable
    # include Statisticianable
    
    METABASE_DASHBOARD_ID = 10

    has_one :ministry_email_whitelist,
            class_name: 'EmailWhitelists::Ministry',
            foreign_key: :user_id,
            dependent: :destroy

    has_many :user_groups,
             foreign_key: :user_id,
             inverse_of: :user
    has_many :groups,
              -> { where is_public: true },
              through: :user_groups

    def ministry_email_whitelist
      EmailWhitelists::Ministry.find_by(email: email)
    end

    def email_whitelist
      ministry_email_whitelist
    end

    def ministries
      groups
    end

    def dashboard_name
      'Statistiques nationales'
    end

    def ministry_statistician? ; true end

    def presenter
      Presenters::MinistryStatistician.new(self)
    end

    def assign_email_whitelist_and_confirm
      # self.ministry_email_whitelist = EmailWhitelists::Ministry.find_by(email: email)
      # self.confirmed_at = Time.now
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
        field :first_name do
          label 'Prénom'
        end
        field :last_name do
          label 'Nom'
        end
        field :email do
          label 'Email'
        end
        # field :group_id do
        #   label 'Ministère'
        #   pretty_value do
        #     bindings[:object]&.group&.name
        #   end
        # end
        field :statistician_validation do
          label 'Validation'
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
    
    def employer_like? ; true end
    
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
