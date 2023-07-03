require "test_helper"

class InternshipOfferAreaTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert build(:internship_offer_area).valid?
  end

  test "creation requires employer" do
    area = create(:internship_offer_area)
    area.employer = nil
    assert area.invalid?
  end

  test "creation requires name" do
    area = create(:internship_offer_area)
    area.name = nil
    assert area.invalid?
  end

  test "creation requires unique name per employer" do
    employer = create(:employer)
    area1 = create(:internship_offer_area, employer: employer)
    area2 = build(:internship_offer_area, employer: employer, name: area1.name)
    area3 = build(:internship_offer_area, name: area1.name)
    assert area2.invalid?
    assert area3.valid?
  end
end
