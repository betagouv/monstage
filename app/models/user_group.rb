class UserGroup < ApplicationRecord
  belongs_to :group,
             -> { where is_public: true },
             foreign_key: :group_id,
             class_name: 'Group'
  belongs_to :user,
             foreign_key: :user_id,
             class_name: 'Users::MinistryStatistician'
end
