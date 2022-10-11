module EmailWhitelists
  class Ministry < EmailWhitelist
    belongs_to :group,
               -> { where is_public: true },
               inverse_of: :ministries,
               foreign_key: :group_id,
               class_name: 'Group'

    validate :public_group?

    rails_admin do
      weight 10
      navigation_label "Listes blanches"
      
      list do
        field :id
        field :email
        field :ministry_name do
          label 'Administration centrale'
          formatted_value { bindings[:object].group.name }
        end
      end

      show do
        field :id
        field :email
        field :ministry_name do
          label 'Administration centrale'
          formatted_value { bindings[:object].group.name }
        end
      end

      edit do
        field :email
        field :group do
          associated_collection_scope do
            Proc.new { |scope| scope.where(is_public: true) }
          end
        end
      end
    end

    protected

    def notify_account_ready
      MinistryStatisticianEmailWhitelistMailer.notify_ready(recipient_email: email)
                                              .deliver_later
    end

    private

    def public_group?
      return if group.is_public

      errors.add(:group_id, 'Le groupe associé doit être public')
    end
  end
end
