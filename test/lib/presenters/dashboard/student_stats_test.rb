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
        create(:weekly_internship_application, student: another_student)
        create(:weekly_internship_application, student: @student)
        assert_equal 1, @student_stats.applications_count
      end

      test '.applications_approved_count' do
        create(:weekly_internship_application, :approved, student: @student)
        create(:weekly_internship_application, :rejected, student: @student)
        create(:weekly_internship_application, :convention_signed, student: @student)
        assert_equal 1, @student_stats.applications_approved_count
      end

      test '.internship_location' do
        internship_offer = create(:weekly_internship_offer, street: '7 rue du puits',
                                                           city: 'Coye la foret',
                                                           zipcode: '60580')
        create(:weekly_internship_application,
               :convention_signed,
               student: @student,
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
        StudentStats::Tutor.new(**tutor_kwargs)
        internship_offer = create(
          :weekly_internship_offer,
          **tutor_kwargs)
        weekly_internship_application = create(
          :weekly_internship_application,
          :convention_signed,
          student: @student,
          internship_offer: internship_offer
        )
        weekly_internship_application.save


        tutor = @student_stats.internship_tutors.first
        assert_equal tutor.tutor_name, internship_offer.tutor_name
        assert_equal tutor.tutor_phone, internship_offer.tutor_phone
        assert_equal tutor.tutor_email, internship_offer.tutor_email
      end
    end
  end
end
