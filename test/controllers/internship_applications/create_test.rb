# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    test 'POST #create internship application as student' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school, weeks: [internship_offer.weeks.first])
      student = create(:student, school: school, class_room: create(:class_room, school: school))
      sign_in(student)
      valid_params = {
        internship_application: {
          week_id: internship_offer.internship_offer_weeks.first.week.id,
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          type: InternshipApplications::WeeklyFramed.name,
          student_attributes: {
            id: student.id,
            resume_other: 'resume_other',
            resume_languages: 'resume_languages'
          },
          student_email: student.email,
          student_phone: '0600119988'
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      assert_equal internship_offer.internship_offer_weeks.first.week.id, created_internship_application.week.id
      assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation.to_plain_text
      assert_equal student.id, created_internship_application.student.id

      student = student.reload
      assert_equal 'resume_other', student.resume_other.to_plain_text
      assert_equal 'resume_languages', student.resume_languages.to_plain_text
      assert_equal '0600119988', created_internship_application.student_phone
      assert_equal student.email, created_internship_application.student_email
    end

    test 'POST #create internship application as student to offer posted by statistician' do
      internship_offer = create(:weekly_internship_offer)
      internship_offer.update(employer_id: create(:statistician).id)
      school = create(:school, weeks: [internship_offer.weeks.first])
      student = create(:student, school: school, class_room: create(:class_room, school: school))
      sign_in(student)
      valid_params = {
        internship_application: {
          week_id: internship_offer.internship_offer_weeks.first.week.id,
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          type: InternshipApplications::WeeklyFramed.name,
          student_attributes: {
            phone: '+330656565400',
            resume_other: 'resume_other',
            resume_languages: 'resume_languages'
          }
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      assert_equal internship_offer.internship_offer_weeks.first.week.id, created_internship_application.week.id
      assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation.to_plain_text
      assert_equal student.id, created_internship_application.student.id

      student = student.reload
      assert_equal '+330656565400', student.phone
      assert_equal 'resume_other', student.resume_other.to_plain_text
      assert_equal 'resume_languages', student.resume_languages.to_plain_text
    end



    test 'POST #create internship application as student without class_room' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school, weeks: [internship_offer.weeks.first])
      student = create(:student, school: school)
      sign_in(student)
      valid_params = {
        internship_application: {
          week_id: internship_offer.internship_offer_weeks.first.week.id,
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          type: InternshipApplications::WeeklyFramed.name,
          student_attributes: {
            phone: '+330656565400',
            resume_other: 'resume_other',
            resume_languages: 'resume_languages'
          }
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      assert_equal internship_offer.internship_offer_weeks.first.week.id, created_internship_application.week.id
      assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation.to_plain_text
      assert_equal student.id, created_internship_application.student.id

      student = student.reload
      assert_equal '+330656565400', student.phone
      assert_equal 'resume_other', student.resume_other.to_plain_text
      assert_equal 'resume_languages', student.resume_languages.to_plain_text
    end

    # create internship application as student with class_room and check that counter are updated
    test 'POST #create internship application as student with greater max_candidates than hosting_info' do
      internship_offer = create(:weekly_internship_offer,
        max_candidates: 3,
        max_students_per_group: 1,
        weeks: Week.selectable_from_now_until_end_of_school_year.first(3))
      internship_offer.hosting_info.update(max_candidates: 3, max_students_per_group: 1, weeks: Week.selectable_from_now_until_end_of_school_year.first(3))

      school = create(:school, weeks: [internship_offer.weeks.first, internship_offer.weeks.last])
      class_room = create(:class_room, school: school)
      student_1 = create(:student, school: school, class_room: class_room)
      student_2 = create(:student, school: school, class_room: class_room)

      a1 = create(:weekly_internship_application,
        :approved,
        internship_offer: internship_offer,
        student: student_1,
        week: internship_offer.internship_offer_weeks.first.week
      )

      InternshipOfferWeek.second.destroy
      # /!\ Now only 2 weeks are available for internship_offer, for 3 max_candidates
      # Application should fail unless offer#enough_weeks validation is skipped as we expect

      sign_in(student_2)

      valid_params = {
        internship_application: {
          week_id: internship_offer.internship_offer_weeks.last.week.id,
          motivation: 'Je suis trop motivé wesh',
          user_id: student_2.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          type: InternshipApplications::WeeklyFramed.name,
          student_attributes: {
            phone: '+330656565400',
            resume_educational_background: 'resume_educational_background',
            resume_other: 'resume_other',
            resume_languages: 'resume_languages'
          }
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do # no failure since validation is not run
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end
    end

    test 'POST #create internship application as student with empty phone in profile' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school, weeks: [internship_offer.weeks.first])
      student = create(:student, school: school, phone: nil, email: 'marc@ms3e.fr', class_room: create(:class_room, school: school))
      sign_in(student)
      valid_params = {
        internship_application: {
          week_id: internship_offer.internship_offer_weeks.first.week.id,
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          student_email: 'julie@ms3e.fr',
          student_phone: '0600119988'
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      student = student.reload
      assert_equal '0600119988', created_internship_application.student_phone
      assert_equal 'julie@ms3e.fr', created_internship_application.student_email
      assert_equal '+330600119988', student.phone # changed
      assert_equal 'marc@ms3e.fr', student.email # unchanged
    end
  
    test 'POST #create internship application as student with empty email in profile' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school, weeks: [internship_offer.weeks.first])
      student = create(:student, school: school, phone: '+330600110011', email: nil, class_room: create(:class_room, school: school))
      sign_in(student)
      valid_params = {
        internship_application: {
          week_id: internship_offer.internship_offer_weeks.first.week.id,
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          student_email: 'marc@ms3e.fr',
          student_phone: '0600000000'
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      student = student.reload
      assert_equal '0600000000', created_internship_application.student_phone
      assert_equal 'marc@ms3e.fr', created_internship_application.student_email
      assert_equal '+330600110011', student.phone # unchanged
      assert_equal 'marc@ms3e.fr', student.email # changed
    end

    test 'POST #create internship application as student with duplicate contact email' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school, weeks: [internship_offer.weeks.first])
      student = create(:student, school: school, phone: '+330600110011', email: nil, class_room: create(:class_room, school: school))
      student_2 = create(:student)
      sign_in(student)
      valid_params = {
        internship_application: {
          week_id: internship_offer.internship_offer_weeks.first.week.id,
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          student_email: student_2.email,
          student_phone: '0600000000'
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 0) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_response :bad_request
      end
    end

    test 'POST #create internship application as student with duplicate contact phone' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school, weeks: [internship_offer.weeks.first])
      student = create(:student, school: school, phone: '+330600110011', class_room: create(:class_room, school: school))
      student_2 = create(:student, phone: '+330600110022')
      sign_in(student)
      valid_params = {
        internship_application: {
          week_id: internship_offer.internship_offer_weeks.first.week.id,
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          student_email: student.email,
          student_phone: student_2.phone.gsub('+33', '')
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 0) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_response :bad_request
      end
    end
  end
end
