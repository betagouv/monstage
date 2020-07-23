# frozen_string_literal: true

require 'test_helper'

module Presenters
  class UserManagemetRoleTest < ActiveSupport::TestCase
    setup do
      @school_manager = Users::SchoolManagement.new(role: :school_manager)
      @teacher = Users::SchoolManagement.new(role: :teacher)
      @other = Users::SchoolManagement.new(role: :other)
      @main_teacher = Users::SchoolManagement.new(role: :main_teacher)
    end

    test '.role_name' do
      assert_equal "Chef d'établissement", UserManagemetRole.new(user: @school_manager).role
      assert_equal 'Professeur', UserManagemetRole.new(user: @teacher).role
      assert_equal 'Autres fonctions', UserManagemetRole.new(user: @other).role
      assert_equal 'Professeur principal', UserManagemetRole.new(user: @main_teacher).role
    end
  end
end
