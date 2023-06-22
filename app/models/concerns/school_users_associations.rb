module SchoolUsersAssociations
  extend ActiveSupport::Concern

  included do
    has_many :users

    has_many :students, dependent: :nullify,
                      class_name: 'Users::Student'

    has_many :school_managements, dependent: :nullify,
                                class_name: 'Users::SchoolManagement'

    has_one :school_manager, -> { where(role: :school_manager) },
            class_name: 'Users::SchoolManagement'
    has_many :main_teachers, -> { where(role: :main_teacher) },
             class_name: 'Users::SchoolManagement'
    has_many :teachers, -> { where(role: :teacher) },
             class_name: 'Users::SchoolManagement'
    has_many :others, -> { where(role: :other) },
             class_name: 'Users::SchoolManagement'
    has_many :cpes, -> { where(role: :cpe) },
             class_name: 'Users::SchoolManagement'
    has_many :admin_officers, -> { where(role: :admin_officer) },
             class_name: 'Users::SchoolManagement'
  end
end
