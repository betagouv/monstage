# frozen_string_literal: true

require 'test_helper'

class InternshipApplicationCountersHookTest < ActiveSupport::TestCase
  setup do
    @week = Week.find_by(number: 1, year: 2019)
    @internship_offer_week = build(:internship_offer_week, week: @week)
    @internship_offer = build(:internship_offer, internship_offer_weeks: [@internship_offer_week])
    @internship_application = build(:internship_application, internship_offer_week: @internship_offer_week,
                                                             internship_offer: @internship_offer)
  end

  #
  # tracks internship_offer_weeks counters
  #
  test '.update_internship_offer_week_counters tracks internship_offer_weeks.blocked_applications_count' do
    @internship_application.aasm_state = :approved
    @internship_application.save!
    assert_changes -> { @internship_offer_week.reload.blocked_applications_count },
                   from: 0,
                   to: 1 do
      @internship_application.signed!
    end
  end

  test '.update_internship_offer_week_counters tracks internship_offer_weeks.approved_applications_count' do
    @internship_application.aasm_state = :submitted
    @internship_application.save!

    assert_changes -> { @internship_offer_week.reload.approved_applications_count },
                   from: 0,
                   to: 1 do
      @internship_application.approve!
    end
  end

  #
  # track internship_offer counters
  #
  test '.update_internship_offer_counters tracks internship_offer.blocked_weeks_count' do
    @internship_application.aasm_state = :approved
    @internship_application.save!

    assert_changes -> { @internship_offer.reload.blocked_weeks_count },
                   from: 0,
                   to: 1 do
      @internship_application.signed!
    end
  end

  test '.update_internship_offer_counters tracks internship_offer.total_applications_count' do
    @internship_application.aasm_state = :submitted
    assert_changes -> { @internship_offer.total_applications_count },
                   from: 0,
                   to: 1 do
      @internship_application.save!
      @internship_offer.reload
    end
  end

  test '.update_internship_offer_counters ignores drafted applications with internship_offer.total_applications_count' do
    create(:internship_application, :drafted, internship_offer_week: @internship_offer_week,
                                              internship_offer: @internship_offer)

    assert_equal 0, @internship_offer.reload.total_applications_count
  end

  test '.update_internship_offer_counters tracks internship_offer.convention_signed_applications_count' do
    @internship_application.aasm_state = :approved
    @internship_application.save!

    assert_changes -> { @internship_offer.reload.convention_signed_applications_count },
                   from: 0,
                   to: 1 do
      @internship_application.signed!
    end
  end

  test '.update_internship_offer_counters tracks internship_offer.approved_applications_count' do
    @internship_application.aasm_state = :submitted
    @internship_application.save!

    assert_changes -> { @internship_offer.reload.approved_applications_count },
                   from: 0,
                   to: 1 do
      @internship_application.approve!
    end
  end

  test '.update_internship_offer_counters tracks total male and female applications_count' do
    @internship_application.student = create(:student, gender: 'm')
    @internship_application.aasm_state = :submitted
    assert_changes -> { @internship_application.internship_offer.total_male_applications_count },
                   from: 0,
                   to: 1 do
      @internship_application.save!
    end

    second_application = build(:internship_application, internship_offer_week: @internship_offer_week, internship_offer: @internship_offer,
                                                        student: create(:student, gender: 'f'))
    second_application.aasm_state = :submitted

    assert_changes -> { second_application.internship_offer.total_female_applications_count },
                   from: 0,
                   to: 1 do
      second_application.save!
    end
  end
end
