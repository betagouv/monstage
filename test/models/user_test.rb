# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  test 'creation requires accept terms' do
    user = Users::SchoolManagement.new
    user.valid?
    assert user.errors.include?(:accept_terms)
    assert_equal user.errors.messages[:accept_terms][0],
                 "Veuillez accepter les conditions d'utilisation"
    user = Users::SchoolManagement.new(accept_terms: '1')
    user.valid?
    refute user.errors.include?(:accept_terms)
  end

  test 'anonymize student' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    student = create(:student, email: 'test@test.com', first_name: 'Toto', last_name: 'Tata',
                               current_sign_in_ip: '127.0.0.1', last_sign_in_ip: '127.0.0.1', birth_date: '01/01/2000',
                               gender: 'm', class_room_id: class_room.id, resume_educational_background: 'Zer',
                               resume_other: 'chocolat', resume_languages: 'FR', phone: '+330600110011',
                               handicap: 'malvoyant')

    assert_enqueued_jobs 1, only: AnonymizeUserJob do
      student.anonymize
    end

    assert_equal 'm', student.gender
    assert_equal class_room.id, student.class_room_id

    assert_not_equal 'test@test.com', student.email
    assert_not_equal 'Toto', student.first_name
    assert_not_equal 'Tata', student.last_name
    assert_not_equal '127.0.0.1', student.current_sign_in_ip
    assert_not_equal '127.0.0.1', student.last_sign_in_ip
    assert_not_equal '01/01/2000', student.birth_date

    assert_equal 'm', student.gender
    assert_equal class_room.id, student.class_room_id
    assert_not_equal 'Zer', student.resume_educational_background
    assert_not_equal 'chocolat', student.resume_other
    assert_not_equal 'chocolat', student.resume_languages
    assert_not_equal 'malvoyant', student.handicap
    assert_not_equal '+330600110011', student.phone
    assert student.anonymized
  end

  test 'anonymize student which email is empty' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    student = create(:student, email: '', first_name: 'Toto', last_name: 'Tata',
                               current_sign_in_ip: '127.0.0.1', last_sign_in_ip: '127.0.0.1', birth_date: '01/01/2000',
                               gender: 'm', class_room_id: class_room.id, resume_educational_background: 'Zer',
                               resume_other: 'chocolat', resume_languages: 'FR', phone: '+330600110011',
                               handicap: 'malvoyant')

    assert_enqueued_jobs 0 do
      student.anonymize
    end

    assert_equal 'm', student.gender
    assert_equal class_room.id, student.class_room_id

    assert_not_equal '', student.email
    assert_not_equal 'Toto', student.first_name
    assert_not_equal 'Tata', student.last_name
    assert_not_equal '127.0.0.1', student.current_sign_in_ip
    assert_not_equal '127.0.0.1', student.last_sign_in_ip
    assert_not_equal '01/01/2000', student.birth_date
    assert_not_equal 'Zer', student.resume_educational_background
    assert_not_equal 'chocolat', student.resume_other
    assert_not_equal 'chocolat', student.resume_languages
    assert_not_equal 'malvoyant', student.handicap
    assert_not_equal '+330600110011', student.phone
    assert student.anonymized
  end

  test 'archive student' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    student = create(:student, email: 'test@test.com', first_name: 'Toto', last_name: 'Tata',
                               current_sign_in_ip: '127.0.0.1', last_sign_in_ip: '127.0.0.1', birth_date: '01/01/2000',
                               gender: 'm', class_room_id: class_room.id, resume_educational_background: 'Zer',
                               resume_other: 'chocolat', resume_languages: 'FR', phone: '+330600110011',
                               handicap: 'malvoyant')

    assert_enqueued_jobs 0, only: AnonymizeUserJob do
      student.archive
    end

    assert_equal true, student.anonymized
  end

  test 'anonymize employer' do
    employer = create(:employer, email: 'test@test.com', first_name: 'Toto', last_name: 'Tata',
                                 current_sign_in_ip: '127.0.0.1', last_sign_in_ip: '127.0.0.1')

    internship_offer = create(:weekly_internship_offer, employer: employer)

    employer.anonymize

    internship_offer.reload
    assert internship_offer.discarded?
  end

  test 'validate email bad' do
    user = build(:employer, email: 'lol')
    refute user.valid?
    assert_equal ['Le format de votre email semble incorrect'], user.errors.messages[:email]
  end
  
  # Remove following tests after 2022/01/01 if Newsletter is already implemented

  # test '#add_to_contacts is called whenever a user is created' do
  #   assert_enqueued_jobs 1, only: AddContactToSyncEmailDeliveryJob do
  #     student = create(:student, confirmed_at: nil)
  #     student.confirm
  #   end
  # end

  # test '#RemoveContactFromSyncEmailDeliveryJob is called whenever a user is anonymized' do
  #   student = create(:student)
  #   assert_enqueued_jobs 1, only: RemoveContactFromSyncEmailDeliveryJob do
  #     student.anonymize
  #   end
  # end

  test "when updating one's email both removing and adding contact jobs are enqueued" do
    student = create(:student)

    assert_enqueued_jobs 1 do
      student.email = "alt_#{student.email}"
      student.save # 1 ==> confirmation mail
      student.confirm # 2 #3 Cannot avoid to launch the job twice. ==> former user update in Contact list | no longer use any job
    end
  end

  test "when updating one's first_name no jobs are enqueued" do
    student = create(:student)
    assert_no_enqueued_jobs do
      student.first_name = "alt_#{student.first_name}"
      student.save
      student.confirm
    end
  end

  test '#reset_password_by_phone when max count' do
    student = create(:student, last_phone_password_reset: 1.hours.ago, phone_password_reset_count: 3)
    student.reset_password_by_phone
    assert_equal student.phone_password_reset_count, 3
    assert student.last_phone_password_reset < 1.minute.ago
  end

  test '#reset_password_by_phone when resetable' do
    student = create(:student, last_phone_password_reset: 1.hours.ago, phone_password_reset_count: 1)
    student.reset_password_by_phone
    assert_equal student.phone_password_reset_count, 2
    assert student.last_phone_password_reset > 1.minute.ago
  end

  test 'formatted_phone' do
    student = create(:student, phone: '+330611223344')
    assert_equal '+33611223344', student.formatted_phone
  end

  test 'user creates his account' do
    mock_mail = MiniTest::Mock.new
    mock_mail.expect(:deliver_later, true)
    CustomDeviseMailer.stub :confirmation_instructions, mock_mail do
      student = create(:student, confirmed_at: nil)
    end
    mock_mail.verify
  end

  test 'user updates his email' do
    student = create(:student)
    mock_mail = MiniTest::Mock.new
    mock_mail.expect(:deliver_later, true)
    CustomDeviseMailer.stub :update_email_instructions, mock_mail do
      student.update(email: 'myemail@mail.com')
    end
    mock_mail.verify
  end

  test 'user adds email' do
    student = create(:student, email: nil, phone: '+330611223344')
    mock_mail = MiniTest::Mock.new
    mock_mail.expect(:deliver_later, true)
    CustomDeviseMailer.stub :add_email_instructions, mock_mail do
      student.update(email: 'myemail@mail.com')
    end
    mock_mail.verify
  end
end
