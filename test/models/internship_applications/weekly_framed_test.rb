# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class InternshipApplicationTest < ActiveSupport::TestCase
    test ':internship_offer_week_id, :has_no_spots_left' do
      max_candidates = 1
      internship_offer_week_1 = build(:internship_offer_week, blocked_applications_count: 1,
                                                              week: Week.find_by(number: 1, year: 2019))
      internship_offer = create(:internship_offer, max_candidates: max_candidates,
                                                          internship_offer_weeks: [
                                                            internship_offer_week_1
                                                          ])
      internship_application = build(:internship_application, week: internship_offer_week_1.week)
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
      internship_offer = create(:internship_offer, max_candidates: max_candidates,
                                                          internship_offer_weeks: [
                                                            internship_offer_week_1,
                                                            internship_offer_week_2,
                                                            internship_offer_week_3
                                                          ])
      internship_application = build(:internship_application, internship_offer: internship_offer_week_3.internship_offer,
                                                                     week: internship_offer_week_3.week)
      internship_application.save
      assert internship_application.errors.include?(:internship_offer)
      assert_equal 1, internship_application.errors.where(:week, :has_no_spots_left).size
    end

    test 'is not applicable twice on same week by same student' do
      weeks = [Week.find_by(number: 1, year: 2019)]
      student = create(:student)
      internship_offer = create(:internship_offer, weeks: weeks)
      internship_application_1 = create(:internship_application, student: student,
                                                                        internship_offer: internship_offer,
                                                                        week: internship_offer.internship_offer_weeks.first.week)
      assert internship_application_1.valid?
      internship_application_2 = build(:internship_application, student: student,
                                                                       internship_offer: internship_offer,
                                                                       week: internship_offer.internship_offer_weeks.first.week)
      refute internship_application_2.valid?
    end

    test 'is not applicable twice on different week by same student' do
      weeks = [Week.find_by(number: 1, year: 2019), Week.find_by(number: 2, year: 2019)]
      student = create(:student)
      internship_offer = create(:internship_offer, weeks: weeks)
      internship_application_1 = create(:internship_application,
                                        internship_offer: internship_offer,
                                        student: student,
                                        week: internship_offer.weeks.first)
      assert internship_application_1.valid?
      internship_application_2 = build(:internship_application,
                                       internship_offer: internship_offer,
                                       student: student,
                                       week: internship_offer.internship_offer_weeks.first.week)
      refute internship_application_2.valid?
    end

    test 'application updates remaining_seats_count along with approved applications' do
      offer = create(:internship_offer)
      assert_equal offer.max_candidates, offer.remaining_seats_count
      application = create(:internship_application, internship_offer: offer)
      assert_equal offer.max_candidates, offer.remaining_seats_count
      assert_equal "drafted", application.aasm_state

      application.submit!
      assert_equal "submitted", application.aasm_state
      assert_equal offer.max_candidates, offer.reload.remaining_seats_count

      application.approve!
      assert_equal "approved", application.aasm_state
      assert_equal 1, application.internship_offer.internship_offer_weeks.first.blocked_applications_count
      assert_equal offer.max_candidates - 1, offer.reload.remaining_seats_count
    end

    test 'application updates offer favorites along with approved applications' do
      offer = create(:internship_offer, max_candidates: 1)
      favorite = create(:favorite, internship_offer: offer)
      assert_equal Favorite.count, 1
      other_favorite = create(:favorite)
      application = create(:internship_application, internship_offer: offer)

      application.submit!
      assert_equal Favorite.count, 2

      application.approve!
      assert_equal "approved", application.aasm_state
      assert_equal Favorite.count, 1
    end

    test 'application updates old offer favorites along with approved applications' do
      old_offer = create(:internship_offer, last_date: 7.days.ago)
      favorite = create(:favorite, internship_offer: old_offer)
      assert_equal Favorite.count, 1
      other_favorite = create(:favorite)
      application = create(:internship_application, internship_offer: old_offer)

      application.submit!
      assert_equal Favorite.count, 2

      application.approve!
      assert_equal "approved", application.aasm_state
      assert_equal Favorite.count, 1
      assert_operator Favorite.last.internship_offer.last_date, :>, Time.now
    end
  end
end
