# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class InternshipApplicationTest < ActiveSupport::TestCase
    test ':internship_offer_week_id, :has_no_spots_left' do
      max_candidates = 1
      internship_offer_week_1 = build(:internship_offer_week, blocked_applications_count: 1,
                                                              week: Week.find_by(number: 1, year: 2019))
      internship_offer = create(:weekly_internship_offer, max_candidates: max_candidates,
                                                          internship_offer_weeks: [
                                                            internship_offer_week_1
                                                          ])
      internship_application = build(:weekly_internship_application, internship_offer_week: internship_offer_week_1)
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
      internship_offer = create(:weekly_internship_offer, max_candidates: max_candidates,
                                                          internship_offer_weeks: [
                                                            internship_offer_week_1,
                                                            internship_offer_week_2,
                                                            internship_offer_week_3
                                                          ])
      internship_application = build(:weekly_internship_application, internship_offer: internship_offer_week_3.internship_offer,
                                                                     internship_offer_week: internship_offer_week_3)
      internship_application.save
      assert internship_application.errors.keys.include?(:internship_offer)
      assert_equal :has_no_spots_left, internship_application.errors.details[:internship_offer].first[:error]
    end

    test 'is not applicable twice on same week by same student' do
      weeks = [Week.find_by(number: 1, year: 2019)]
      student = create(:student)
      internship_offer = create(:weekly_internship_offer, weeks: weeks)
      internship_application_1 = create(:weekly_internship_application, student: student,
                                                                        internship_offer: internship_offer,
                                                                        internship_offer_week: internship_offer.internship_offer_weeks.first)
      assert internship_application_1.valid?
      internship_application_2 = build(:weekly_internship_application, student: student,
                                                                       internship_offer: internship_offer,
                                                                       internship_offer_week: internship_offer.internship_offer_weeks.first)
      refute internship_application_2.valid?
    end

    test 'is not applicable twice on different week by same student' do
      weeks = [Week.find_by(number: 1, year: 2019), Week.find_by(number: 2, year: 2019)]
      student = create(:student)
      internship_offer = create(:weekly_internship_offer, weeks: weeks)
      internship_application_1 = create(:weekly_internship_application,
                                        internship_offer: internship_offer,
                                        student: student,
                                        internship_offer_week: internship_offer.internship_offer_weeks.first)
      assert internship_application_1.valid?
      internship_application_2 = build(:weekly_internship_application,
                                       internship_offer: internship_offer,
                                       student: student,
                                       internship_offer_week: internship_offer.internship_offer_weeks.last)
      refute internship_application_2.valid?
    end

    test 'transition via signed! cancel internship_application.student other applications on same week' do
      weeks = [weeks(:week_2019_1), weeks(:week_2019_2)]
      student = create(:student)
      student_2 = create(:student)
      internship_offer_1 = create(:weekly_internship_offer, weeks: weeks)
      internship_offer_2 = create(:weekly_internship_offer, weeks: weeks)
      internship_application_to_be_canceled_by_employer = create(
        :weekly_internship_application, :approved,
        internship_offer_week: internship_offer_1.internship_offer_weeks.first,
        student: student
      )
      internship_application_to_be_signed = create(:weekly_internship_application, :approved,
                                                   internship_offer: internship_offer_2,
                                                   internship_offer_week: internship_offer_2.internship_offer_weeks.first,
                                                   student: student)
      internship_application_ignored_by_week = create(:weekly_internship_application, :approved,
                                                      internship_offer: internship_offer_1,
                                                      internship_offer_week: internship_offer_1.internship_offer_weeks.last,
                                                      student: student_2)
      internship_application_ignored_by_student = create(:weekly_internship_application, :approved,
                                                         internship_offer: internship_offer_1,
                                                         internship_offer_week: internship_offer_1.internship_offer_weeks.first)
      assert_changes -> { internship_application_to_be_canceled_by_employer.reload.aasm_state },
                     from: 'approved',
                     to: 'expired' do
        internship_application_to_be_signed.signed!
      end
      assert internship_application_ignored_by_week.reload.approved?
      assert internship_application_ignored_by_student.reload.approved?
    end
  end
end
