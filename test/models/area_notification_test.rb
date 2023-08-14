require "test_helper"

class AreaNotificationTest < ActiveSupport::TestCase
  include TeamAndAreasHelper

  test "single_human_in_charge" do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    offer = create_internship_offer_visible_by_two(employer_1, employer_2)
    assert_equal 4 , AreaNotification.count
    assert_equal 2 , InternshipOfferArea.count
    InternshipOfferArea.all.each do |area|
      refute area.single_human_in_charge?
    end
    employer_1.current_area.area_notifications.first.update(notify: false)
    assert employer_1.current_area.single_human_in_charge?


  end
end
