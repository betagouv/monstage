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

      test '.applications_best_status' do
        student = create(:student)
        assert_equal({ color: 'warning', label: 'doit faire des candidatures' },
                     @student_stats.applications_best_status)
        create(:weekly_internship_application, :drafted, student: student)
        assert_equal({ color: 'warning', label: 'doit faire des candidatures' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :expired, student: student)
	      assert_equal({ color: 'error ', label: 'candidature expirée' },
                     StudentStats.new(student: student.reload).applications_best_status)
        assert_equal({ color: 'error ', label: 'candidature expirée' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :rejected, student: student)
        assert_equal({ color: 'error', label: 'candidature refusée' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :expired_by_student, student: student)
        assert_equal({ color: 'error', label: 'candidature refusée' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :canceled_by_student, student: student)
        assert_equal({ color: 'error', label: 'candidature refusée' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :canceled_by_student_confirmation, student: student)
        assert_equal({ color: 'error', label: 'candidature refusée' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :canceled_by_employer, student: student)
        assert_equal({ color: 'error', label: 'candidature refusée' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :submitted, student: student)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :read_by_employer, student: student)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :examined, student: student)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :validated_by_employer, student: student)
        assert_equal({ color: 'new', label: "confirmer la venue dans l'entreprise" },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :approved, student: student)
        assert_equal({ color: 'success', label: 'stage accepté' },
                     StudentStats.new(student: student.reload).applications_best_status)
      end
    end
  end
end
