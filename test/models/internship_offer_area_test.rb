require "test_helper"

class InternshipOfferAreaTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert build(:area).valid?
  end

  test "api factory is valid" do
    assert build(:api_area).valid?
  end

  test "creation requires employer" do
    area = create(:area)
    area.employer = nil
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
    area = create(:area)
    employer = area.employer
    offer = create(:weekly_internship_offer, internship_offer_area: area)
    assert_equal 1, area.internship_offers.count
    assert employer.internship_offers.count.positive?
    assert_equal area, employer.internship_offers.first.internship_offer_area
    assert_equal employer, employer.internship_offers.first.internship_offer_area.employer
    assert_equal offer, employer.internship_offers.first
  end
end
