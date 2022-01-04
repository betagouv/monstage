class Invitation < ApplicationRecord
  belongs_to :user,
             class_name: "user",
             foreign_key: "user_id"
  # school_managements includes different roles
  # 1. school_manager should register with ac-xxx.fr email
  # 2.3.4. can register
  enum role: {
    teacher: 'teacher',
    main_teacher: 'main_teacher',
    other: 'other'
  }

end
