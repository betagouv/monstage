module StudentAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        fields(*UserAdmin::DEFAULT_FIELDS)
        field :school
        field :class_room
        fields(*UserAdmin::ACCOUNT_FIELDS)

        scopes(UserAdmin::DEFAULT_SCOPES)
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
