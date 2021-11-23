# frozen_string_literal: true

require 'test_helper'

class InternshipOfferTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'create enqueue SyncInternshipOfferKeywordsJob' do
    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      create(:weekly_internship_offer)
    end
  end

  test 'destroy enqueue SyncInternshipOfferKeywordsJob' do
    internship_offer = create(:weekly_internship_offer)

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.destroy
    end
  end

  test 'update title enqueues SyncInternshipOfferKeywordsJob' do
    internship_offer = create(:weekly_internship_offer)

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(title: 'bingo bango bang')
    end

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(description_rich_text: 'bingo bango bang')
    end

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(employer_description_rich_text: 'bingo bango bang')
    end

    assert_enqueued_jobs 0, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(first_date: 2.days.from_now)
    end
  end

  test 'faulty zipcode' do
    internship_offer = create(:weekly_internship_offer)
    internship_offer.update_columns(zipcode: 'xy75012')

    refute internship_offer.valid?
    assert_equal ["Code postal le code postal ne permet pas de déduire le département" ],
                 internship_offer.errors.full_messages
  end


  test 'internship_offer.available_weeks for past year offer returns selectable_on_past_school_year' do
    travel_to(Date.new(2021, 5, 31)) do
      school_year_n_plus_one = SchoolYear::Floating.new_by_year(year: 2020)
      assert_equal Date.new(2020, 9, 1), school_year_n_plus_one.beginning_of_period
      assert_equal Date.new(2021, 5, 31), school_year_n_plus_one.end_of_period

      school_year_n_minus_one = SchoolYear::Floating.new_by_year(year: 2019)
      assert_equal Date.new(2019, 9, 1), school_year_n_minus_one.beginning_of_period
      assert_equal Date.new(2020, 5, 31), school_year_n_minus_one.end_of_period

      first_week = Week.where(year: school_year_n_minus_one.beginning_of_period.year,
                              number: school_year_n_minus_one.beginning_of_period.cweek)
                       .first

      internship_offer = create(:weekly_internship_offer, weeks: [first_week])

      first = internship_offer.available_weeks.first
      last = internship_offer.available_weeks.last
      assert_equal Week.selectable_for_school_year(school_year: school_year_n_minus_one).first,
                   first
      assert_equal Week.selectable_for_school_year(school_year: school_year_n_minus_one).last,
                   last
    end
  end
end
