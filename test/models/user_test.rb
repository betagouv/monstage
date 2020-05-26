# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  test 'creation requires accept terms' do
    user = Users::SchoolManagement.new
    user.valid?
    assert user.errors.keys.include?(:accept_terms)
    assert_equal user.errors.messages[:accept_terms][0],
                 "Veuillez accepter les conditions d'utilisation"
    user = Users::SchoolManagement.new(accept_terms: "1")
    user.valid?
    refute user.errors.keys.include?(:accept_terms)
  end

  test 'School manager creation' do
    school_manager = Users::SchoolManagement.create(email: 'chef@etablissement.com',
                                                 password: 'tototo',
                                                 password_confirmation: 'tototo',
                                                 first_name: 'Chef',
                                                 last_name: 'Etablissement',
                                                 school: build(:school),
                                                 accept_terms: true)

    assert school_manager.invalid?
    assert_not_empty school_manager.errors[:email]

    school_manager = Users::SchoolManagement.create(email: 'chef@ac-etablissement.com',
                                                 password: 'tototo',
                                                 password_confirmation: 'tototo',
                                                 first_name: 'Chef',
                                                 last_name: 'Etablissement',
                                                 school: build(:school),
                                                 accept_terms: true)
    assert school_manager.valid?
  end

  test 'RGPD student' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    student = create(:student, email: 'test@test.com', first_name: 'Toto', last_name: 'Tata',
      current_sign_in_ip: '127.0.0.1', last_sign_in_ip: '127.0.0.1', birth_date: '01/01/2000',
      gender: 'm', class_room_id: class_room.id, resume_educational_background: 'Zer',
      resume_other: 'chocolat', resume_languages: 'FR',
      handicap: 'malvoyant')

    assert_enqueued_jobs 1, only: AnonymizeUserJob do
      student.anonymize
    end

    assert_not_equal 'test@test.com', student.email
    assert_not_equal 'Toto', student.first_name
    assert_not_equal 'Tata', student.last_name
    assert_not_equal '127.0.0.1', student.current_sign_in_ip
    assert_not_equal '127.0.0.1', student.last_sign_in_ip
    assert_not_equal '01/01/2000', student.birth_date
    assert_not_equal 'm', student.gender
    assert_not_equal class_room.id, student.class_room_id
    assert_not_equal 'Zer', student.resume_educational_background
    assert_not_equal 'chocolat', student.resume_other
    assert_not_equal 'chocolat', student.resume_languages
    assert_not_equal 'malvoyant', student.handicap

  end

  test 'RGPD employer' do
    employer = create(:employer, email: 'test@test.com', first_name: 'Toto', last_name: 'Tata',
      current_sign_in_ip: '127.0.0.1', last_sign_in_ip: '127.0.0.1')

    internship_offer = create(:internship_offer, employer: employer)

    employer.anonymize

    internship_offer.reload
    assert internship_offer.discarded?
  end

  test 'validate email bad' do
    user = build(:employer, email: 'lol')
    refute user.valid?
    assert_equal ["Le format de votre email semble incorrect"], user.errors.messages[:email]
  end
end
