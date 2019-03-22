require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome,
                       screen_size: [1400, 1400]

  def visit_signup
    visit "/"
    click_on "Mes stages"
    page.find("a[href='#{users_choose_profile_path}'").click
  end
end
