# frozen_string_literal: true

require 'test_helper'
module InternshipApplicationCountersHooks
  class FreeDateTest < ActiveSupport::TestCase
    setup do
      @internship_offer = build(:free_date_internship_offer)
      @internship_application = build(:free_date_internship_application,
                                      internship_offer: @internship_offer)
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
      @internship_offer.save!
      @internship_application.aasm_state = :drafted

      assert_no_changes -> { @internship_offer.reload.total_applications_count } do
        @internship_application.save!
      end
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

    test '.update_internship_offer_counters tracks total male and female applications_count and even more' do
      @internship_application.student = create(:student, gender: 'm')
      @internship_application.aasm_state = :submitted
      assert_changes -> { @internship_application.internship_offer.total_male_applications_count },
                     from: 0,
                     to: 1 do
        @internship_application.save!
      end

      second_application = build(:free_date_internship_application,
                                 internship_offer: @internship_offer,
                                 student: create(:student, gender: 'f'))
      second_application.aasm_state = :submitted

      assert_changes -> { second_application.internship_offer.total_female_applications_count },
                     from: 0,
                     to: 1 do
        second_application.save!
      end
      third_application = build(:free_date_internship_application,
                                 internship_offer: @internship_offer,
                                 student: create(:student, gender: 'np'))
      third_application.aasm_state = :submitted

      assert_changes -> { third_application.internship_offer.total_no_gender_applications_count },
                     from: 0,
                     to: 1 do
        third_application.save!
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
