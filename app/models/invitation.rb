class Invitation < ApplicationRecord
  belongs_to :school_manager, -> { where(role: :school_manager) },
             class_name: 'Users::SchoolManagement', foreign_key: 'user_id'

  enum role: {
    teacher: 'Professeur',
    main_teacher: 'Professeur principal',
    other: 'Autre'
  }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true
  validates :email,
            format: { with: Devise.email_regexp },
            on: :create
end
