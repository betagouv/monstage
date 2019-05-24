# frozen_string_literal: true

class NamespaceUsers < ActiveRecord::Migration[5.2]
  def change
    User.where(type: 'SchoolManager').update_all(type: 'Users::SchoolManager')
    User.where(type: 'Student').update_all(type: 'Users::Student')
    User.where(type: 'Employer').update_all(type: 'Users::Employer')
    User.where(type: 'God').update_all(type: 'Users::God')
  end
end
