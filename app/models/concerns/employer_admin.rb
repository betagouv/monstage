module EmployerAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      weight 3
      
      list do
        fields(*UserAdmin::DEFAULT_FIELDS)
        fields(*UserAdmin::ACCOUNT_FIELDS)

        scopes(UserAdmin::DEFAULT_SCOPES)
      end

      edit do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
      end
    end
  end
end
