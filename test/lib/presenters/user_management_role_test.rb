# frozen_string_literal: true

require 'test_helper'

module Presenters
  class UserManagementRoleTest < ActiveSupport::TestCase
    setup do
      @school_manager = Users::SchoolManagement.new(role: :school_manager)
      @teacher = Users::SchoolManagement.new(role: :teacher)
      @other = Users::SchoolManagement.new(role: :other)
      @main_teacher = Users::SchoolManagement.new(role: :main_teacher)
    end

    test '.role_name' do
      assert_equal "Chef d'établissement", UserManagementRole.new(user: @school_manager).role
      assert_equal 'Professeur', UserManagementRole.new(user: @teacher).role
      assert_equal 'Autres fonctions', UserManagementRole.new(user: @other).role
      assert_equal 'Professeur principal', UserManagementRole.new(user: @main_teacher).role
    end

  end
end
