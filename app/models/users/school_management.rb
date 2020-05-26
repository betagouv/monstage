# frozen_string_literal: true

module Users
  class SchoolManagement < User
    include UserAdmin
    enum role: [ :school_manager, :teacher, :main_teacher, :other ]
  end
end
