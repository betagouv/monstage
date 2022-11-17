class MinistryGroup < ApplicationRecord
  belongs_to :group,
             -> { where is_public: true },
             foreign_key: :group_id,
             class_name: 'Group'
  belongs_to :ministries,
             foreign_key: :email_whitelist_id,
             class_name: 'EmailWhitelists::Ministry'
end
