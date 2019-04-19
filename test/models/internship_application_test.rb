require 'test_helper'

class InternshipApplicationTest < ActiveSupport::TestCase

  test "can create application if offer is not full" do
    internship_offer = create(:internship_offer, max_candidates: 1)
    internship_offer_week = internship_offer.internship_offer_weeks.first
    internship_application = build(:internship_application, internship_offer_week: internship_offer_week)
    assert internship_application.valid?
  end

  test "cannot create application if offer is full" do
    max_candidates = 1
    internship_offer_week = build(:internship_offer_week, blocked_applications_count: max_candidates,
                                                          week: Week.first)
    internship_offer = create(:internship_offer, max_candidates: max_candidates,
                                                 internship_offer_weeks: [internship_offer_week])
    internship_application = build(:internship_application, internship_offer_week: internship_offer_week)
    refute internship_application.valid?
  end

  test 'transition from submited to approved send approved email' do
    internship_application = create(:internship_application, :submitted)
    freeze_time do
      assert_changes -> { internship_application.reload.approved_at },
                     from: nil,
                     to: Date.today do
        mock_mail = MiniTest::Mock.new
        mock_mail.expect(:deliver_later, true)
        StudentMailer.stub :internship_application_approved_email, mock_mail do
          internship_application.save
          internship_application.approve!
        end
        mock_mail.verify
      end
    end
  end

  test 'transition from submited to rejected send rejected email' do
    internship_application = create(:internship_application, :submitted)
    freeze_time do
      assert_changes -> { internship_application.reload.rejected_at },
                     from: nil,
                     to: Date.today do
        mock_mail = MiniTest::Mock.new
        mock_mail.expect(:deliver_later, true)
        StudentMailer.stub :internship_application_rejected_email, mock_mail do
          internship_application.reject!
        end
        mock_mail.verify
      end
    end
  end

  test 'transition via cancel! changes aasm_state from approved to rejected' do
    internship_application = create(:internship_application, :approved)
    assert_changes -> { internship_application.reload.aasm_state },
                   from: 'approved',
                   to: 'rejected' do
      freeze_time do
        assert_changes -> { internship_application.reload.rejected_at },
                       from: nil,
                       to: Date.today do
          internship_application.cancel!
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
                       to: Date.today do
          internship_application.signed!
        end
      end
    end
  end

  test 'is not applicable twice by same student' do
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
end
