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
    end
  end
end
