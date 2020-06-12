# frozen_string_literal: true

require 'test_helper'

class InternshipApplicationTest < ActiveSupport::TestCase
  test 'can create application if offer is not full' do
    internship_offer = create(:internship_offer, max_candidates: 1)
    internship_offer_week = internship_offer.internship_offer_weeks.first
    internship_application = build(:internship_application, internship_offer_week: internship_offer_week)
    assert internship_application.valid?
  end

  test ':internship_offer_week_id, :has_no_spots_left' do
    max_candidates = 1
    internship_offer_week_1 = build(:internship_offer_week, blocked_applications_count: 1,
                                                            week: Week.find_by(number: 1, year: 2019))
    internship_offer = create(:internship_offer, max_candidates: max_candidates,
                                                 internship_offer_weeks: [
                                                  internship_offer_week_1,
                                                 ])
    internship_application = build(:internship_application, internship_offer_week: internship_offer_week_1)
    internship_application.save
    assert internship_application.errors.keys.include?(:internship_offer_week)
    assert_equal :has_no_spots_left, internship_application.errors.details[:internship_offer_week].first[:error]
  end

  test ':internship_offer, :has_no_spots_left' do
    max_candidates = 1
    internship_offer_week_1 = build(:internship_offer_week, blocked_applications_count: 1,
                                                            week: Week.find_by(number: 1, year: 2019))
    internship_offer_week_2 = build(:internship_offer_week, blocked_applications_count: 1,
                                                            week: Week.find_by(number: 2, year: 2019))
    internship_offer_week_3 = build(:internship_offer_week, blocked_applications_count: 1,
                                                            week: Week.find_by(number: 3, year: 2019))
    internship_offer = create(:internship_offer, max_candidates: max_candidates,
                                                 internship_offer_weeks: [
                                                  internship_offer_week_1,
                                                  internship_offer_week_2,
                                                  internship_offer_week_3
                                                 ])
    internship_application = build(:internship_application, internship_offer_week: internship_offer_week_3)
    internship_application.save
    assert internship_application.errors.keys.include?(:internship_offer)
    assert_equal :has_no_spots_left, internship_application.errors.details[:internship_offer].first[:error]
  end


  test 'is not applicable twice on same week by same student' do
    weeks = [Week.find_by(number: 1, year: 2019)]
    student = create(:student)
    internship_offer = create(:internship_offer, weeks: weeks)
    internship_application_1 = create(:internship_application, student: student,
                                                               internship_offer_week: internship_offer.internship_offer_weeks.first)
    assert internship_application_1.valid?
    internship_application_2 = build(:internship_application, student: student,
                                                              internship_offer_week: internship_offer.internship_offer_weeks.first)
    refute internship_application_2.valid?
  end

  test 'is not applicable twice on different week by same student' do
    weeks = [Week.find_by(number: 1, year: 2019), Week.find_by(number: 2, year: 2019)]
    student = create(:student)
    internship_offer = create(:internship_offer, weeks: weeks)
    internship_application_1 = create(:internship_application, student: student,
                                                               internship_offer_week: internship_offer.internship_offer_weeks.first)
    assert internship_application_1.valid?
    internship_application_2 = build(:internship_application, student: student,
                                                              internship_offer_week: internship_offer.internship_offer_weeks.last)
    refute internship_application_2.valid?
  end

  test 'transition from draft to submit updates submitted_at and send semail to employer' do
    internship_application = create(:internship_application, :drafted)
    freeze_time do
      assert_changes -> { internship_application.reload.submitted_at },
                     from: nil,
                     to: Time.now.utc do
        mock_mail = MiniTest::Mock.new
        mock_mail.expect(:deliver_later, true)
        EmployerMailer.stub :internship_application_submitted_email, mock_mail do
          internship_application.submit!
        end
        mock_mail.verify
      end
    end
  end

  test 'transition from submited to approved send approved email to student' do
    internship_application = create(:internship_application, :submitted)

    freeze_time do
      assert_changes -> { internship_application.reload.approved_at },
                     from: nil,
                     to: Time.now.utc do
        mock_mail_to_student = MiniTest::Mock.new
        mock_mail_to_student.expect(:deliver_later, true)
        StudentMailer.stub :internship_application_approved_email, mock_mail_to_student do
          internship_application.save
          internship_application.approve!
        end
        mock_mail_to_student.verify
      end
    end
  end

  test 'transition from submited to approved send approved email to main_teacher' do
    internship_application = create(:internship_application, :submitted)
    student = internship_application.student
    create(:school_manager, school: student.school)
    create(:main_teacher, class_room: student.class_room,
                          school: student.school)

    mock_mail_to_main_teacher = MiniTest::Mock.new
    mock_mail_to_main_teacher.expect(:deliver_later, true)

    MainTeacherMailer.stub(:internship_application_approved_email,
                       mock_mail_to_main_teacher) do
      internship_application.save
      internship_application.approve!
    end
    mock_mail_to_main_teacher.verify
  end

  test 'transition from submited to rejected send rejected email to student' do
    internship_application = create(:internship_application, :submitted)
    freeze_time do
      assert_changes -> { internship_application.reload.rejected_at },
                     from: nil,
                     to: Time.now.utc do
        mock_mail = MiniTest::Mock.new
        mock_mail.expect(:deliver_later, true)
        StudentMailer.stub :internship_application_rejected_email, mock_mail do
          internship_application.reject!
        end
        mock_mail.verify
      end
    end
  end

  test 'transition from rejected to approved send approved email' do
    internship_application = create(:internship_application, :rejected)
    freeze_time do
      assert_changes -> { internship_application.reload.approved_at },
                     from: nil,
                     to: Time.now.utc do
        mock_mail = MiniTest::Mock.new
        mock_mail.expect(:deliver_later, true)
        StudentMailer.stub :internship_application_approved_email, mock_mail do
          internship_application.approve!
        end
        mock_mail.verify
      end
    end
  end

  test 'transition via cancel_by_employer! changes ' \
       'aasm_state from approved to rejected' do
    internship_application = create(:internship_application, :approved)
    assert_changes -> { internship_application.reload.aasm_state },
                   from: 'approved',
                   to: 'canceled_by_employer' do
      freeze_time do
        assert_changes -> { internship_application.reload.canceled_at },
                       from: nil,
                       to: Time.now.utc do
          mock_mail = MiniTest::Mock.new
          mock_mail.expect(:deliver_later, true)
          StudentMailer.stub :internship_application_canceled_by_employer_email,
                              mock_mail do
                              internship_application.cancel_by_employer!
          end
          mock_mail.verify
        end
      end
    end
  end

  test 'transition via expire! changes aasm_state from submitted to expired' do
    internship_application = create(:internship_application, :submitted)
    assert_changes -> { internship_application.reload.aasm_state },
                   from: 'submitted',
                   to: 'expired' do
      freeze_time do
        assert_changes -> { internship_application.reload.expired_at },
                       from: nil,
                       to: Time.now.utc do
          internship_application.expire!
        end
      end
    end
  end

  test 'transition via signed! changes aasm_state from approved to rejected' do
    internship_application = create(:internship_application, :approved)
    assert_changes -> { internship_application.reload.aasm_state },
                   from: 'approved',
                   to: 'convention_signed' do
      freeze_time do
        assert_changes -> { internship_application.reload.convention_signed_at },
                       from: nil,
                       to: Time.now.utc do
          internship_application.signed!
        end
      end
    end
  end

  test 'transition via signed! cancel internship_application.student other applications on same week' do
    weeks = [weeks(:week_2019_1), weeks(:week_2019_2)]
    student = create(:student)
    student_2 = create(:student)
    internship_offer_1 = create(:internship_offer, weeks: weeks)
    internship_offer_2 = create(:internship_offer, weeks: weeks)
    internship_application_to_be_canceled_by_employer = create(
      :internship_application, :approved,
      internship_offer_week: internship_offer_1.internship_offer_weeks.first,
      student: student
    )
    internship_application_to_be_signed = create(:internship_application, :approved,
                                                 internship_offer_week: internship_offer_2.internship_offer_weeks.first,
                                                 student: student)
    internship_application_ignored_by_week = create(:internship_application, :approved,
                                                    internship_offer_week: internship_offer_1.internship_offer_weeks.last,
                                                    student: student_2)
    internship_application_ignored_by_student = create(:internship_application, :approved,
                                                       internship_offer_week: internship_offer_1.internship_offer_weeks.first)
    assert_changes -> { internship_application_to_be_canceled_by_employer.reload.aasm_state },
                   from: 'approved',
                   to: 'expired' do
      internship_application_to_be_signed.signed!
    end
    assert internship_application_ignored_by_week.reload.approved?
    assert internship_application_ignored_by_student.reload.approved?
  end

  test 'RGPD' do
    internship_application = create(:internship_application, motivation: 'amazing')

    internship_application.anonymize

    assert_not_equal 'amazing', internship_application.motivation
  end
end
