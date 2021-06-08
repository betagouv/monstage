module EmailWhitelists
  class Ministry < EmailWhitelist
    validates :group_id, inclusion: {in: Group.is_public.ids}

    belongs_to :group,
               -> { where is_public: true },
               inverse_of: :ministries

    rails_admin do
      list do
        field :id
        field :email
        field :ministry_name do
          label 'Entité publique'
          formatted_value { bindings[:object].group.name }
        end
      end

      show do
        field :id
        field :email
        field :ministry_name do
          label 'Entité publique'
          formatted_value { bindings[:object].group.name }
        end
      end

      edit do
        configure :group do
          associated_collection_scope do
            resource_scope = bindings[:object].class.reflect_on_association(:group).source_reflection.scope
            proc do |scope|
              resource_scope ? scope.merge(resource_scope) : scope
            end
          end
        end
        field :email
        field :group , :belongs_to_association
      end
    end

    protected

    def notify_account_ready
      MinistryStatisticianEmailWhitelistMailer.notify_ready(recipient_email: email)
                                              .deliver_later
    end
  end
end