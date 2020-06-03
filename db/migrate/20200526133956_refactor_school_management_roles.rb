class RefactorSchoolManagementRoles < ActiveRecord::Migration[6.0]
  def up
    User.where(type: 'Users::Teacher')
        .update_all(role: 'teacher', type: 'Users::SchoolManagement')
    User.where(type: 'Users::MainTeacher')
        .update_all(role: 'main_teacher', type: 'Users::SchoolManagement')
    User.where(type: 'Users::SchoolManager')
        .update_all(role: 'school_manager', type: 'Users::SchoolManagement')
    User.where(type: 'Users::Other')
        .update_all(role: 'other', type: 'Users::SchoolManagement')
  end
end
