# frozen_string_literal: true

require 'test_helper'
module SchoolYear
  class ArchiverTest < ActiveSupport::TestCase
    if ENV['RUN_BRITTLE_TEST']
      test '.school_end_year_archiving ' do
        internship_offer = nil
        next_week        = nil
        final_week_id    = 0
        preparation_date = Date.new(2021, 1, 31)
        execution_date   = Date.new(2021, 8, 15)

        travel_to preparation_date do
          next_week = Week.next
          final_week_id = next_week.id + 52
          internship_offer = create(:weekly_internship_offer,
                                    weeks: [
                                      next_week,
                                      Week.find_by(id: final_week_id)]
          )
        end
        travel_to execution_date do
          school = create(:school)
          student = create(:student,
                          school_id: school.id,
                          first_name: 'student_first_name',
                          last_name: 'student_last_name',
                          phone: '+330611223344',
                          current_sign_in_ip: "0.0.0.0",
                          last_sign_in_ip: '0.0.0.0',
                          birth_date: 14.years.ago,
                          handicap: 'handicap',
                          resume_educational_background: 'resume_educational_background',
                          resume_other: 'resume_other',
                          resume_languages: 'resume_languages')
          employer = create(:employer)
          create(:weekly_internship_application,
                  internship_offer: internship_offer,
                  motivation: 'Motivation',
                  student: student)
          student2 = create(:student, school_id: school.id)

          Monstage::Application.load_tasks
          Rake::Task['school_end_year_archiving'].invoke do

            assert_empty Users::Student.all.kept

            discarded_student = Users::Student.find(student.id)
            assert_equal "NA", discarded_student.first_name
            assert_equal "NA", discarded_student.last_name
            assert_nil discarded_student.phone
            assert_nil discarded_student.current_sign_in_ip
            assert_nil discarded_student.last_sign_in_ip
            assert_nil discarded_student.birth_date
            assert_nil discarded_student.handicap
            assert_empty discarded_student.resume_educational_background
            assert_empty discarded_student.resume_other
            assert_empty discarded_student.resume_languages
            discarded_student.internship_applications.each do |internship_application|
              assert_empty internship_application.motivation
            end
            assert discarded_student.anonymized

            assert_equal 2, InternshipOffer.all.count

            assert internship_offer.reload.kept?
            assert_equal 1, internship_offer.weeks.count
            assert_equal next_week.id, internship_offer.weeks.first.id
            assert internship_offer.employer_hidden

            new_internship_offer = InternshipOffer.all.order(created_at: :desc).first
            refute new_internship_offer.employer_hidden
            assert_equal final_week_id, new_internship_offer.weeks.first.id
          end
        end
      end

      test '.school_end_year_archiving out of period' do
        internship_offer = nil
        next_week = nil
        preparation_date = Date.new(2021, 1, 31)
        final_week_id = 0
        travel_to preparation_date do
          next_week = Week.next
          final_week_id = next_week.id + 52
          internship_offer = create(:weekly_internship_offer,
                                    weeks: [
                                      next_week,
                                      Week.find_by(id: final_week_id)]
          )
        end
        travel_to Date.new(2021, 5 , 1) do
          school = create(:school)
          student = create(:student,
                          school_id: school.id,
                          first_name: 'student_first_name',
                          last_name: 'student_last_name',
                          phone: '+330611223344',
                          current_sign_in_ip: "0.0.0.0",
                          last_sign_in_ip: '0.0.0.0',
                          birth_date: 14.years.ago,
                          handicap: 'handicap',
                          resume_educational_background: 'resume_educational_background',
                          resume_other: 'resume_other',
                          resume_languages: 'resume_languages')
          employer = create(:employer)
          create(:weekly_internship_application,
                  internship_offer: internship_offer,
                  motivation: 'Motivation',
                  student: student)
          student2 = create(:student, school_id: school.id)

          Monstage::Application.load_tasks
          Rake::Task['school_end_year_archiving'].invoke do
            assert_equal 2, InternshipOffer.all.count

            assert internship_offer.reload.kept?
            assert_equal 1, internship_offer.weeks.count
            assert_equal next_week.id, internship_offer.weeks.first.id
            assert internship_offer.employer_hidden

            new_internship_offer = InternshipOffer.all.order(created_at: :desc).first
            refute new_internship_offer.employer_hidden
            assert_equal final_week_id, new_internship_offer.weeks.first.id
          end
        end
      end
    end
  end
end
