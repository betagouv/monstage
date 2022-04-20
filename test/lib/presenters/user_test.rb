# frozen_string_literal: true

require 'test_helper'

module Presenters
  class UserTest < ActiveSupport::TestCase
    delegate :application, to: Rails
    delegate :routes, to: :application
    delegate :url_helpers, to: :routes

    test '.default_internship_offers_path with nil user, works' do
      assert_equal url_helpers.internship_offers_path, Presenters::User.new(nil).default_internship_offers_path
    end

    test '.default_internship_offers_path with employer user returns to all offers' do
      employer = create(:employer)
      assert_equal url_helpers.internship_offers_path, employer.presenter.default_internship_offers_path
    end

    test '.default_internship_offers_path with main_teacher having no school returns to all offers' do
      school_manager = create(:school_manager)
      main_teacher = create(:main_teacher, school: school_manager.school)
      main_teacher.update!(school_id: nil, class_room_id: nil)
      assert_equal url_helpers.internship_offers_path, main_teacher.presenter.default_internship_offers_path
    end

    test '.default_internship_offers_path with main_teacher having a school returns to offers prefiltered for his school' do
      school_manager = create(:school_manager)
      main_teacher = create(:main_teacher, school: school_manager.school)

      assert_equal url_helpers.internship_offers_path(school_manager.default_search_options),
                   main_teacher.presenter.default_internship_offers_path
    end

    test '.default_internship_offers_path with student having a school/school_track also include school_track param' do
      school_manager = create(:school_manager)
      class_room = create(:class_room, :troisieme_generale, school: school_manager.school)
      student = create(:student, school: school_manager.school, class_room: class_room)

      assert_equal url_helpers.internship_offers_path(student.default_search_options),
                   student.presenter.default_internship_offers_path
    end

   test '.default_internship_offers_path with school_manager having a school with weeks does not prefilter by weeks' do
      weeks =  [Week.selectable_from_now_until_end_of_school_year.first]
      school = create(:school, weeks: weeks)
      school_manager = create(:school_manager, school: school)
      class_room = create(:class_room, :troisieme_generale, school: school_manager.school)

      url_options = school_manager.default_search_options
      assert url_options.key?(:week_ids), 'missing weeks params'
      assert url_options.key?(:school_track), 'missing school_track params'
    end

    test '.default_internship_offers_path includes expected params' do
      school = create(:school, weeks: Week.selectable_from_now_until_end_of_school_year[1..2])
      school_manager = create(:school_manager, school: school)
      class_room = create(:class_room, :troisieme_generale, school: school)
      student = create(:student, school: school, class_room: class_room)
      path = student.presenter.default_internship_offers_path
      params = CGI.parse(URI.parse(path).query)
      assert_equal [school.city], params["city"]
      assert_equal [school.coordinates.lat.to_s], params["latitude"]
      assert_equal [school.coordinates.lon.to_s], params["longitude"]
      assert_equal [Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER.to_s], params["radius"]
      assert_equal school.week_ids.map(&:to_s), params["week_ids[]"]
      assert_equal [student.school_track], params["school_track"]
    end

    test '#civil_name' do
      student = build(:student, gender: nil)
      assert_equal student.last_name, student.presenter.civil_name
      student = build(:student, gender: 'np')
      assert_equal student.last_name, student.presenter.civil_name
      student = build(:student, gender: 'm')
      assert_equal "Monsieur #{student.last_name}", student.presenter.civil_name
      student = build(:student, gender: 'f')
      assert_equal "Madame #{student.last_name}", student.presenter.civil_name
    end
  end
end
