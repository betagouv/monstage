# frozen_string_literal: true

require 'test_helper'
module InternshipApplicationCountersHooks
  class WeeklyFramedTest < ActiveSupport::TestCase
    setup do
      @week = Week.find_by(number: 1, year: 2019)
      @internship_offer = create(:weekly_internship_offer, weeks: [@week])
      @internship_application = build(:weekly_internship_application, week: @week,
                                                                      internship_offer: @internship_offer)
    end

    #
    # tracks internship_offer_weeks counters
    #
    # SIGNED !
    # test '.update_internship_offer_week_counters tracks internship_offer_weeks.blocked_applications_count' do
    #   @internship_application.aasm_state = :approved
    #   @internship_application.save!
    #   assert_equal 1, @internship_offer.internship_offer_weeks
    #                                    .reload
    #                                    .first
    #                                    .blocked_applications_count
    #   # @Maxime : On comprend donc ci-dessous que la signature d'une candidature libère la semaine 
    #   # réservée jusque là dans internship_offer_week. C'est étrange mais
    #   # c'est le sens de expire_application_on_week. Moi, ça me gêne
    #   assert_changes -> { @internship_offer.internship_offer_weeks.reload.first.blocked_applications_count },
    #                  from: 1,
    #                  to: 0 do
    #     @internship_application.signed!
    #   end
    # end

    #
    # track internship_offer counters
    #
    # SIGNED !
    # test '.update_internship_offer_counters tracks internship_offer.blocked_weeks_count' do
    #   @internship_application.aasm_state = :approved
    #   @internship_application.save!

    #   assert_equal 1, @internship_offer.reload.blocked_weeks_count
    #   # @Maxime : On comprend donc ci-dessous que la signature d'une candidature
    #   #  libère une place réservée jusque là. C'est étrange mais
    #   # c'est le sens de expire_application_on_week. Moi, ça me gêne
    #   assert_changes -> { @internship_offer.reload.blocked_weeks_count },
    #                  from: 1,
    #                  to: 0 do
    #     @internship_application.signed!
    #   end
    # end

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
      create(:weekly_internship_application, :drafted,
             week: @internship_offer.weeks.first,
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

    test '.update_internship_offer_counters tracks internship_offer.total_male_approved_applications_count when student is male' do
      @internship_application.aasm_state = :submitted
      @internship_application.save!

      assert_changes -> { @internship_offer.reload.total_male_approved_applications_count },
                     from: 0,
                     to: 1 do
        @internship_application.approve!
      end
    end

    test '.update_internship_offer_counters does not tracks internship_offer.total_male_approved_applications_count when student is female' do
      @internship_application.student = create(:student, gender: 'f')
      @internship_application.aasm_state = :submitted
      @internship_application.save!

      assert_no_changes -> { @internship_offer.reload.total_male_approved_applications_count } do
        @internship_application.approve!
      end
    end

    test '.update_internship_offer_counters does not tracks internship_offer.total_male_approved_applications_count when student does not precise gender' do
      @internship_application.student = create(:student, gender: 'np')
      @internship_application.aasm_state = :submitted
      @internship_application.save!

      assert_no_changes -> { @internship_offer.reload.total_male_approved_applications_count } do
        @internship_application.approve!
      end
    end

    test '.update_internship_offer_counters tracks internship_offer.total_custom_track_approved_applications_count when student is custom track' do
      @internship_application.student = create(:student, custom_track: true)
      @internship_application.aasm_state = :submitted
      @internship_application.save!
      assert_changes -> { @internship_application.internship_offer.reload.total_custom_track_approved_applications_count },
                     from: 0,
                     to: 1 do
        @internship_application.approve!
      end
    end

    test '.update_internship_offer_counters tracks internship_offer.total_custom_track_approved_applications_count when student is not custom track' do
      @internship_application.student = create(:student, custom_track: false)
      @internship_application.aasm_state = :submitted
      @internship_application.save!
      assert_no_changes -> { @internship_application.internship_offer.reload.total_custom_track_approved_applications_count } do
        @internship_application.approve!
      end
    end

    test '.update_internship_offer_counters tracks internship_offer.rejected_applications_count' do
      @internship_application.aasm_state = :submitted
      @internship_application.save!

      assert_changes -> { @internship_offer.reload.rejected_applications_count },
                     from: 0,
                     to: 1 do
        @internship_application.reject!
      end
    end

    test '.update_internship_offer_counters tracks internship_offer.submitted_applications_count' do
      @internship_application.aasm_state = :drafted
      @internship_application.save!

      assert_changes -> { @internship_offer.reload.submitted_applications_count },
                     from: 0,
                     to: 1 do
        @internship_application.submit!
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

      second_application = build(:weekly_internship_application, week: @internship_offer.weeks.first,
                                                                 internship_offer: @internship_offer,
                                                                 student: create(:student, gender: 'f'))
      second_application.aasm_state = :submitted

      assert_changes -> { second_application.internship_offer.total_female_applications_count },
                     from: 0,
                     to: 1 do
        second_application.save!
      end
    end

    test '.update_internship_offer_counters ignores students.custom_track when application is in submitted' do
      @internship_application.student = create(:student, custom_track: true)
      @internship_application.aasm_state = :submitted
      assert_no_changes -> { @internship_application.internship_offer.total_custom_track_convention_signed_applications_count } do
        @internship_application.save!
      end
    end

    test '.update_internship_offer_counters ignores students.custom_track when tracks students.custom_track when application is in convention_signed' do
      @internship_application.student = create(:student, custom_track: true)
      @internship_application.aasm_state = :convention_signed
      assert_changes -> { @internship_application.internship_offer.total_custom_track_convention_signed_applications_count },
                     from: 0,
                     to: 1 do
        @internship_application.save!
      end
    end
  end
end
