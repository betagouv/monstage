module EmailWhitelists
  class Ministry < EmailWhitelist
    has_many :ministry_groups,
             foreign_key: :email_whitelist_id,
             inverse_of: :ministries
    has_many :groups,
              -> { where is_public: true },
              through: :ministry_groups

    validate :all_public_group?

    rails_admin do
      weight 10
      navigation_label "Listes blanches"

      list do
        field :id
        field :email
        field :ministry_name do
          label 'Administration centrale'
          formatted_value { bindings[:object].groups.map(&:name).join(', ') }
        end
      end

      show do
        field :id
        field :email
        field :ministry_names do
          label 'Administration centrale'
          formatted_value { bindings[:object].groups.map(&:name).join(', ') }
        end
      end

      edit do
        field :email
        field :groups do
          associated_collection_scope do
            Proc.new do |scope| 
              scope.is_public
            end
          end
        end
      end

      configure :ministry_grid_associations do
        visible(false)
      end
    end


    def destroy
      Users::MinistryStatistician.find_by(email: email).destroy
      super
    end

    protected

    def notify_account_ready
      MinistryStatisticianEmailWhitelistMailer.notify_ready(recipient_email: email)
                                              .deliver_later
    end

    private

    def all_public_group?
      return if groups.any? && groups.all?(&:is_public?)

      errors.add(:group_id, 'Tous les groupes associés doivent être publics')
    end
  end
end
