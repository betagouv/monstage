# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class SchoolsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # Edit, SchoolManagement
    #
    test 'GET edit not logged redirects to sign in' do
      school = create(:school)
      get edit_dashboard_school_path(school.to_param)
      assert_redirected_to user_session_path
    end

    test 'GET edit as Student redirects to root path' do
      school = create(:school)
      sign_in(create(:student))
      get edit_dashboard_school_path(school.to_param)
      assert_redirected_to root_path
    end

    test 'GET edit as School Manager works' do
      available_weeks = Week.selectable_on_school_year
      school_weeks = Week.selectable_on_school_year[0..1]
      school = create(:school, weeks: school_weeks)
      sign_in(create(:school_manager, school: school))

      internship_offer = create(:weekly_internship_offer, weeks: school_weeks)

      class_room = create(:class_room, school: school)
      student = create(:student, school: school, class_room: class_room)

      internship_application = create(:weekly_internship_application,
                                      student: student,
                                      internship_offer_week: internship_offer.internship_offer_weeks.first)


      get edit_dashboard_school_path(school.to_param)

      assert_response :success
      assert_select 'title', 'Semaines de stage | Monstage'
      assert_select 'form[action=?]', dashboard_school_path(school)
      assert_select('label[for="all_year_long"]',
                    {count: 0},
                    'rendering select all weeks for school manager does not makes sense for school management')
      assert_select('div[data-test="select-week-legend"]',
                    {count: 0},
                    'rendering legend on select-weeks does not makes sense for school management')
      available_weeks.each do |week|
        if week.id == internship_application.internship_offer_week.week.id
          assert_select("input#school_week_ids_#{week.id}_checkbox[disabled='disabled']",
                        { count: 1 },
                        "internship_application week should not be selectable")
        assert_select("input#school_week_ids_#{week.id}_hidden",
                        { count: 1 },
                        "internship_application week should have an hidden field")
        else
          assert_select("input#school_week_ids_#{week.id}_checkbox[disabled='disabled']",
                        { count: 0 },
                        "other week should not be not selectable")

          assert_select("input#school_week_ids_#{week.id}_checkbox",
                        { count: 1 },
                        "other week should be selectable")
        end
      end
    end
    test 'GET class_rooms#index as SchoolManagement shows UX critical alert-info' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)

      sign_in(school_manager)
      get edit_dashboard_school_path(school.to_param)

      assert_select '.alert.alert-info p', text: "Renseignez les classes pour permettre aux enseignants (et aux élèves) de s'inscrire."
      assert_select '.alert.alert-info p', text: 'Indiquez les semaines de stage afin que les offres proposées aux élèves correspondent à ces dates.'
    end

    test 'GET edit as God works' do
      school = create(:school)
      sign_in(create(:god))

      get edit_dashboard_school_path(school.to_param)

      assert_response :success
      assert_select 'form[action=?]', dashboard_school_path(school)
    end

    #
    # Update as Visitor
    #
    test 'PATCH update not logged redirects to sign in' do
      school = create(:school)
      patch(dashboard_school_path(school.to_param),
            params: {
              school: {
                weeks_ids: [weeks(:week_2019_1).id, weeks(:week_2019_2).id]
              }
            })
      assert_redirected_to user_session_path
    end

    test 'PATCH update as Student redirects to root path' do
      school = create(:school)
      sign_in(create(:student))
      patch(dashboard_school_path(school.to_param),
            params: {
              school: {
                weeks_ids: [weeks(:week_2019_1).id, weeks(:week_2019_2).id]
              }
            })
      assert_redirected_to root_path
    end

    test 'PATCH update as SchoolManagement update school & redirect to class rooms' do
      school = create(:school)
      sign_in(create(:school_manager, school: school))
      weeks_ids = [weeks(:week_2019_1).id, weeks(:week_2019_2).id]
      assert_difference('SchoolInternshipWeek.count', weeks_ids.size) do
        patch(dashboard_school_path(school.to_param),
              params: {
                school: {
                  week_ids: weeks_ids
                }
              })
        assert_redirected_to dashboard_school_class_rooms_path(school)
        follow_redirect!
        assert_select '#alert-success #alert-text', { text: 'Etablissement mis à jour avec succès' }, 1
      end
    end

    test 'PATCH update with missing params fails gracefuly' do
      school = create(:school)
      sign_in(create(:school_manager, school: school))
      patch(dashboard_school_path(school.to_param), params: {})
      assert_response :unprocessable_entity
    end
  end
end
