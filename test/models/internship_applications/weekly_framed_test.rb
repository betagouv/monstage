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
      internship_application = build(:weekly_internship_application, week: internship_offer_week_1.week)
      internship_application.save
      assert internship_application.errors.include?(:week)
      assert_equal 1, internship_application.errors.where(:week, :has_no_spots_left).size
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
                                                                     week: internship_offer_week_3.week)
      internship_application.save
      assert internship_application.errors.include?(:internship_offer)
      assert_equal 1, internship_application.errors.where(:week, :has_no_spots_left).size
    end

    test 'is not applicable twice on same week by same student' do
      weeks = [Week.find_by(number: 1, year: 2019)]
      student = create(:student)
      internship_offer = create(:weekly_internship_offer, weeks: weeks)
      internship_application_1 = create(:weekly_internship_application, student: student,
                                                                        internship_offer: internship_offer,
                                                                        week: internship_offer.internship_offer_weeks.first.week)
      assert internship_application_1.valid?
      internship_application_2 = build(:weekly_internship_application, student: student,
                                                                       internship_offer: internship_offer,
                                                                       week: internship_offer.internship_offer_weeks.first.week)
      refute internship_application_2.valid?
    end

    test 'is not applicable twice on different week by same student' do
      weeks = [Week.find_by(number: 1, year: 2019), Week.find_by(number: 2, year: 2019)]
      student = create(:student)
      internship_offer = create(:weekly_internship_offer, weeks: weeks)
      internship_application_1 = create(:weekly_internship_application,
                                        internship_offer: internship_offer,
                                        student: student,
                                        week: internship_offer.weeks.first)
      assert internship_application_1.valid?
      internship_application_2 = build(:weekly_internship_application,
                                       internship_offer: internship_offer,
                                       student: student,
                                       week: internship_offer.internship_offer_weeks.first.week)
      refute internship_application_2.valid?
    end
  end
end
