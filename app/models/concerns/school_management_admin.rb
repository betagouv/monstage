module SchoolManagementAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      weight 4
      list do
        fields(*UserAdmin::DEFAULT_FIELDS)
        field :school
        fields(*UserAdmin::ACCOUNT_FIELDS)

        scopes(UserAdmin::DEFAULT_SCOPES)
      end

      edit do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
        field :school
        field :role
      end
    end
  end
end
