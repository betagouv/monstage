require "test_helper"

class InternshipOfferAreaTest < ActiveSupport::TestCase
  include TeamAndAreasHelper
  test "factory is valid" do
    assert build(:area).valid?
  end

  test "api factory is valid" do
    assert build(:api_area).valid?
  end

  test "creation requires employer" do
    area = build(:area, employer_id: nil)
    assert area.invalid?
  end

  test "creation requires name" do
    area = create(:area)
    area.name = nil
    assert area.invalid?
  end

  test "creation requires unique name per employer" do
    employer = create(:employer)
    area1 = create(:area, employer: employer)
    area2 = build(:area, employer: employer, name: area1.name)
    area3 = build(:area, name: area1.name)
    assert area2.invalid?
    assert area3.valid?
  end

  test "user can access internship_offers" do
    employer, offer = create_employer_and_offer
    area = offer.internship_offer_area
    assert_equal 1, area.internship_offers.count
    assert employer.internship_offers.count.positive?
    assert_equal area, employer.internship_offers.first.internship_offer_area
    assert_equal employer, employer.internship_offers.first.internship_offer_area.employer
    assert_equal offer, employer.internship_offers.first
  end

  test "team's areas are shared" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    internship_offer = create_internship_offer_visible_by_two(employer_1, employer_2)
    assert_equal 2, employer_1.internship_offer_areas.count
    assert_equal 2, employer_2.internship_offer_areas.count
    create(:area, name: "placido_domingo", employer: employer_1)
    assert_equal 3, employer_1.internship_offer_areas.count
    assert_equal 3, employer_2.internship_offer_areas.count
  end

  test "areas do not share offers" do
    employer, offer = create_employer_and_offer
    area = offer.internship_offer_area
    new_area = create(:area, name: "placido_domingo", employer: employer)
    assert_equal 1, employer.internship_offers.count
    employer.current_area_id_memorize(new_area.id)
    assert_equal 0, employer.internship_offers.count
  end
end
