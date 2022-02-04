require 'webdrivers/chromedriver'
Webdrivers::Chromedriver.required_version = '97.0.4692.71'

module CapybaraExtension
  class ApplicationSystemTestCase < ActionDispatch::SystemTestCase

    # overriding the `fill_in` helper for filling in strings with an `@` symbol
    def fill_in(locator = nil, with:, currently_with: nil, fill_options: {}, **find_options)
      return super unless with.include? "@"

      find_options[:with] = currently_with if currently_with
      find_options[:allow_self] = true if locator.nil?
      element = find(:fillable_field, locator, **find_options)
      email_start, email_end = with.split("@")

      element.send_keys(email_start)
      page.driver.browser.action
          .key_down(Selenium::WebDriver::Keys[:alt])
          .send_keys('g')
          .key_up(Selenium::WebDriver::Keys[:alt])
          .perform
      element.send_keys(email_end)
    end
  end
end
