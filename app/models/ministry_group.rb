class MinistryGroup < ApplicationRecord
  belongs_to :group,
             -> { where is_public: true },
             foreign_key: :group_id,
             class_name: 'Group'
end
