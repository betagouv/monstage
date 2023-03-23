# frozen_string_literal: true

require 'test_helper'
module SchoolYear
  class ArchiverTest < ActiveSupport::TestCase
    test '.school_end_year_archiving ' do
      internship_offer = nil
      travel_to Date.new(2021, 1, 31) do
        week = Week.next
        internship_offer = create(:weekly_internship_offer,
                                   weeks: [
                                     week,
                                     Week.find_by(id: (week.id + 52))]
        )
      end
      travel_to Date.new(2021, 8 ,15) do
        school = create(:school)
        student = create(:student,
                        school_id: school.id,
                        first_name: 'test',
                        last_name: 'test',
                        phone: '+330611223344',
                        current_sign_in_ip: "0.0.0.0",
                        last_sign_in_ip: '0.0.0.0',
                        birth_date: 14.years.ago,
                        handicap: 'handicap',
                        resume_educational_background: 'resume_educational_background',
                        resume_other: 'resume_other',
                        resume_languages: 'resume_languages')
        create(:weekly_internship_application, motivation: 'Motivation')
        student2 = create(:student, school_id: school.id)

        Monstage::Application.load_tasks
        Rake::Task['school_end_year_archiving'].invoke

        sleep 1.5

        assert_empty Users::Student.kept

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

        assert internship_offer.reload.kept?
        assert_equal 1, internship_offer.weeks.count
        assert_equal Week.next.id, internship_offer.weeks.first.id
        assert internship_offer.employer_hidden

        new_internship_offer = InternshipOffer.all.order(created_at: :desc).first
        refute new_internship_offer.employer_hidden
        assert_equal 1, new_internship_offer.weeks.first.id

      end
    end
  end
end
