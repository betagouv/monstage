class RefactorSchoolManagementRoles < ActiveRecord::Migration[6.0]
  def up
    User.where(type: 'User::Teacher')
        .update_all(role: 'teacher', type: 'User::SchoolManagement')
    User.where(type: 'User::MainTeacher')
        .update_all(role: 'main_teacher', type: 'User::SchoolManagement')
    User.where(type: 'User::SchoolManager')
        .update_all(role: 'school_manager', type: 'User::SchoolManagement')
    User.where(type: 'User::Other')
        .update_all(role: 'other', type: 'User::SchoolManagement')
  end
end
