# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include TeamAndAreasHelper

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
                               gender: 'm', class_room_id: class_room.id,
                               resume_other: 'chocolat', resume_languages: 'FR', phone: '+330600110011')
    internship_application = create(
      :weekly_internship_application,
      student: student,
      motivation: 'a wonderful world',
      student_phone: '33601254118',
      student_email: 'test@free.fr'
    )
    assert internship_application.motivation.present?
    assert_equal 'a wonderful world', internship_application.motivation.body.to_plain_text

    assert_enqueued_jobs 1, only: AnonymizeUserJob do
      student.anonymize
    end

    assert_equal 'm', student.gender
    assert_nil  internship_application.reload.motivation.body
    assert_nil internship_application.student_phone
    assert_nil internship_application.student_email
    assert_nil student.class_room_id

    assert_not_equal 'test@test.com', student.email
    assert_not_equal 'Toto', student.first_name
    assert_not_equal 'Tata', student.last_name
    assert_not_equal '127.0.0.1', student.current_sign_in_ip
    assert_not_equal '127.0.0.1', student.last_sign_in_ip
    assert_not_equal '01/01/2000', student.birth_date

    assert_equal 'm', student.gender
    assert_nil student.class_room_id
    assert_not_equal 'chocolat', student.resume_other
    assert_not_equal 'chocolat', student.resume_languages
    assert_not_equal '+330600110011', student.phone
    assert student.anonymized
  end

  test 'anonymize student which email is empty' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    student = create(:student, email: '', first_name: 'Toto', last_name: 'Tata',
                               current_sign_in_ip: '127.0.0.1', last_sign_in_ip: '127.0.0.1', birth_date: '01/01/2000',
                               gender: 'm', class_room_id: class_room.id,
                               resume_other: 'chocolat', resume_languages: 'FR', phone: '+330600110011')

    assert_enqueued_jobs 0 do
      student.anonymize
    end

    assert_equal 'm', student.gender
    assert_nil student.class_room_id

    assert_not_equal '', student.email
    assert_not_equal 'Toto', student.first_name
    assert_not_equal 'Tata', student.last_name
    assert_not_equal '127.0.0.1', student.current_sign_in_ip
    assert_not_equal '127.0.0.1', student.last_sign_in_ip
    assert_not_equal '01/01/2000', student.birth_date
    assert_not_equal 'chocolat', student.resume_other
    assert_not_equal 'chocolat', student.resume_languages
    assert_not_equal '+330600110011', student.phone
    assert student.anonymized
  end

  test 'archive student' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    student = create(:student, email: 'test@test.com', first_name: 'Toto', last_name: 'Tata',
                               current_sign_in_ip: '127.0.0.1', last_sign_in_ip: '127.0.0.1', birth_date: '01/01/2000',
                               gender: 'm', class_room_id: class_room.id,
                               resume_other: 'chocolat', resume_languages: 'FR', phone: '+330600110011')

    assert_enqueued_jobs 0, only: AnonymizeUserJob do
      student.archive
    end

    assert_equal true, student.anonymized
  end

  test 'anonymize employer' do
    employer = create(:employer, email: 'test@test.com', first_name: 'Toto', last_name: 'Tata',
                                 current_sign_in_ip: '127.0.0.1', last_sign_in_ip: '127.0.0.1')

    internship_offer = create(:weekly_internship_offer,
                              employer: employer,
                              internship_offer_area: employer.current_area)

    employer.anonymize

    internship_offer.reload
    assert internship_offer.discarded?
  end

  test 'anonymize employer when in a team' do
    employer   = create(:employer)
    employer_2 = create(:employer)

    internship_offer = create_internship_offer_visible_by_two(employer, employer_2)
    assert_equal employer.id, internship_offer.employer_id

    employer.anonymize

    assert employer_2.id, internship_offer.reload.employer_id
    assert employer_2.team.not_exists?

    internship_offer.reload
    refute internship_offer.discarded?
  end

  test 'anonymize employer when in a team with tree' do
    employer   = create(:employer)
    employer_2 = create(:employer)
    employer_3 = create(:employer)

    internship_offer = create_internship_offer_visible_by_two(employer, employer_2)
    create(:team_member_invitation, :accepted_invitation, inviter_id: employer.id, member_id: employer_3.id)
    assert_equal 3, employer.team.team_size
    assert_equal employer.id, internship_offer.employer_id

    employer.anonymize

    assert employer_3.id, internship_offer.reload.employer_id
    assert employer_3.team.alive?
    assert employer_2.team.alive?

    internship_offer.reload
    refute internship_offer.discarded?
  end

  test 'validate email bad' do
    user = build(:employer, email: 'lol')
    refute user.valid?
    assert_equal ['Le format de votre email semble incorrect'], user.errors.messages[:email]
  end

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
    mock_mail = Minitest::Mock.new
    mock_mail.expect(:deliver_later, true)
    CustomDeviseMailer.stub :confirmation_instructions, mock_mail do
      create(:employer, confirmed_at: nil)
    end
    mock_mail.verify
  end

  test 'user updates his email' do
    student = create(:student)
    mock_mail = Minitest::Mock.new
    mock_mail.expect(:deliver_later, true)
    CustomDeviseMailer.stub :update_email_instructions, mock_mail do
      student.update(email: 'myemail@mail.com')
    end
    mock_mail.verify
  end

  test 'user adds email' do
    student = create(:student, email: nil, phone: '+330611223344')
    student.update(email: 'myemail@mail.com')
    assert true, student.confirmed?
  end

  test '#formatted_phone' do
    user = build(:student)
    phone = user[:phone]
    assert_nil user.formatted_phone

    user = build(:student, phone: '+330123654789')
    phone = user[:phone]
    assert_equal '+33123654789', user.formatted_phone

    user = build(:student, phone: '')
    phone = user[:phone]
    assert_nil user.formatted_phone
  end

  test '.sanitize_mobile_phone_number' do
    prefix = '+33'
    number = '+33 6 12 34 56 78'
    assert_equal '+33612345678', User.sanitize_mobile_phone_number(number, prefix)
    number = '+33 06.  12 34 56 78'
    assert_equal '+33612345678', User.sanitize_mobile_phone_number(number, prefix)

    prefix = ''
    numbers = ['+33 (0)6.  12 ..34    56 78',
               '+33 06.  12 ..34    56 78',
               '+33 6.  12 ..34    56 78',
               '33 06.  12 ..34    56 78',
               '33 6.  12 ..34    56 78',
               '06.  12 ..34    56 78' ]
    numbers.each do |number|
      assert_equal '612345678', User.sanitize_mobile_phone_number(number, prefix)
    end
    numbers = ['+33 2.  12 ..34    56 78',
               '02.  12 ..34    56 78',
               '06.  12 ..34    56 7',
               '06.  12 ..34    56 78 9'
              ]
    numbers.each do |number|
      assert_nil User.sanitize_mobile_phone_number(number, prefix)
    end
  end

  test 'employer gets an internship_offer_area' do
    employer = create(:employer)
    assert employer.current_area
  end

  test 'ministry_statistician gets an internship_offer_area' do
    ministry_statistician = create(:ministry_statistician)
    assert ministry_statistician.current_area
  end
end
