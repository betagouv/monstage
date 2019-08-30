# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'creation requires accept terms' do
    user = Users::SchoolManager.new
    user.valid?
    assert user.errors.keys.include?(:accept_terms)
    assert_equal user.errors.messages[:accept_terms][0],
                 "Veuillez accepter les conditions d'utilisation"
    user = Users::SchoolManager.new(accept_terms: "1")
    user.valid?
    refute user.errors.keys.include?(:accept_terms)
  end

  test 'School manager creation' do
    school_manager = Users::SchoolManager.create(email: 'chef@etablissement.com',
                                                 password: 'tototo',
                                                 password_confirmation: 'tototo',
                                                 first_name: 'Chef',
                                                 last_name: 'Etablissement',
                                                 school: build(:school),
                                                 accept_terms: true)

    assert school_manager.invalid?
    assert_not_empty school_manager.errors[:email]

    school_manager = Users::SchoolManager.create(email: 'chef@ac-etablissement.com',
                                                 password: 'tototo',
                                                 password_confirmation: 'tototo',
                                                 first_name: 'Chef',
                                                 last_name: 'Etablissement',
                                                 school: build(:school),
                                                 accept_terms: true)
    assert school_manager.valid?
  end
end
