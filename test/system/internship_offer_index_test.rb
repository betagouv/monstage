# frozen_string_literal: true

require 'application_system_test_case'

class InternshipOfferIndexTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers

  def assert_presence_of(internship_offer:)
    assert_selector "a[data-test-id='#{internship_offer.id}']",
                    count: 1
  end

  def assert_absence_of(internship_offer:)
    assert_no_selector "a[data-test-id='#{internship_offer.id}']"
  end

  test 'navigation & interaction works' do
    school = create(:school)
    student = create(:student, school: school)
    internship_offer = create(:weekly_internship_offer)
    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        visit internship_offers_path

        assert_presence_of(internship_offer: internship_offer)
      end
    end
  end

  test 'navigation & interaction works for employer' do
    employer = create(:employer)
    internship_offer = create(:weekly_internship_offer, employer: employer)
    old_internship_offer = create(:last_year_weekly_internship_offer, employer: employer)
    sign_in(employer)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        visit dashboard_internship_offers_path

        assert_presence_of(internship_offer: internship_offer)
        assert_absence_of(internship_offer: old_internship_offer)
        # click on dépubliées
        find('ul.test-dashboard-nav').find('li:nth-child(2)').find('a').click
        assert_absence_of(internship_offer: internship_offer)
        assert_absence_of(internship_offer: old_internship_offer)
        # click on passed
        find('ul.test-dashboard-nav').find('li:nth-child(3)').find('a').click
        assert_absence_of(internship_offer: internship_offer)
        assert_presence_of(internship_offer: old_internship_offer)
        # click on en cours
        find('ul.test-dashboard-nav').find('li:nth-child(1)').find('a').click
        assert_presence_of(internship_offer: internship_offer)
        assert_absence_of(internship_offer: old_internship_offer)
      end
    end
  end

  test 'visitor is lured into thinking he can submit an application' do
    create(:weekly_internship_offer)
    visit internship_offers_path
    page.find_link('Je postule')
  end

  test 'student can see a school_track filter restricted to his own ' \
       'school_track when she belongs to a troisieme generale class_room' do
    school = create(:school)
    class_room = create(:class_room, school_track: :troisieme_generale, school: school)
    student = create(:student, school: school, class_room: class_room)

    sign_in(student)
    visit internship_offers_path
    assert_equal "",
                 page.find_by_id("input-search-school-track").find(:xpath, 'option[1]').value
    assert_equal 'troisieme_generale',
                 page.find_by_id("input-search-school-track").find(:xpath, 'option[2]').value
    assert_selector("#input-search-school-track option", count: 2)
  end

  test 'student can see a school_track filter restricted to his own ' \
       'school_track when she belongs to a 3e segpa ' do
    school = create(:school)
    class_room = create(:class_room, school_track: :troisieme_segpa, school: school)
    student = create(:student, school: school, class_room: class_room)

    sign_in(student)
    visit internship_offers_path
    assert_equal "",
                 page.find_by_id("input-search-school-track").find(:xpath, 'option[1]').value
    assert_equal 'troisieme_segpa',
                 page.find_by_id("input-search-school-track").find(:xpath, 'option[2]').value
    assert_selector("#input-search-school-track option", count: 2)
  end
end
