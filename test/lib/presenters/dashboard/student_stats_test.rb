# frozen_string_literal: true

require 'test_helper'

module Presenters
  module Dashboard
    class StudentStatsTest < ActiveSupport::TestCase
      setup do
        @student = create(:student)
        @student_stats = StudentStats.new(student: @student)
      end

      test '.applications_count' do
        another_student = create(:student)
        create(:internship_application, :weekly, student: another_student)
        create(:internship_application, :weekly, student: @student)
        assert_equal 1, @student_stats.applications_count
      end

      test '.applications_approved_count' do
        create(:internship_application, :weekly, :approved, student: @student)
        create(:internship_application, :weekly, :rejected, student: @student)
        create(:internship_application, :weekly, :convention_signed, student: @student)
        assert_equal 1, @student_stats.applications_approved_count
      end

      test '.applications_with_convention_signed_count' do
        create(:internship_application, :weekly, :approved, student: @student)
        create(:internship_application, :weekly, :rejected, student: @student)
        create(:internship_application, :weekly, :convention_signed, student: @student)
        create(:internship_application, :weekly, :convention_signed, student: @student)
        create(:internship_application, :weekly, :convention_signed, student: @student)
        assert_equal 3, @student_stats.applications_with_convention_signed_count
      end

      test '.internship_location' do
        internship_offer = build(:internship_offer, street: '7 rue du puits',
                                                    city: 'Coye la foret',
                                                    zipcode: '60580')
        create(:internship_application, :weekly, :convention_signed, student: @student,
                                                            internship_offer: internship_offer)
        assert_equal [internship_offer.formatted_autocomplete_address],
                     @student_stats.internship_locations
      end

      test '.internship_tutors' do
        tutor_kwargs = {
          tutor_name: 'Martin Fourcade',
          tutor_phone: '0669696969',
          tutor_email: 'kikoolol@gmail.com'
        }
        tutors = StudentStats::Tutor.new(**tutor_kwargs)
        internship_offer = build(:internship_offer, **tutor_kwargs)
        create(:internship_application, :weekly, :convention_signed, student: @student,
                                                            internship_offer: internship_offer)

        tutor = @student_stats.internship_tutors.first
        assert_equal tutor.tutor_name, internship_offer.tutor_name
        assert_equal tutor.tutor_phone, internship_offer.tutor_phone
        assert_equal tutor.tutor_email, internship_offer.tutor_email
      end
    end
  end
end
