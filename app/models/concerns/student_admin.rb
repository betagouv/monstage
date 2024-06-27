module StudentAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      weight 2
      
      list do
        fields(*UserAdmin::DEFAULT_FIELDS)
        field :school
        field :class_room
        fields(*UserAdmin::ACCOUNT_FIELDS)

        scopes(UserAdmin::DEFAULT_SCOPES)
        field :failed_attempts do
          label 'Echecs de <br/>connexion'.html_safe
          pretty_value do
            "#{bindings[:object].failed_attempts} / #{bindings[:object].class.maximum_attempts} #{bindings[:object].access_locked? ? '- bloqué' : ''}"
          end
        end
      end

      edit do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
        field :birth_date
        field :school
        field :gender
      end
    end
  end
end
