# frozen_string_literal: true

require 'fileutils'

module Html5Validator
  W3C_RESPONSE_STORED_DIR = Rails.root.join('tmp', 'w3c')
  SCREENSHOT_STORED_DIR = Rails.root.join('tmp', 'functional_screenshots')

  def self.screenshot_files
    Dir["#{SCREENSHOT_STORED_DIR}/*"]
  end

  def self.w3c_files_to_validates
    Dir["#{W3C_RESPONSE_STORED_DIR}/*"]
  end

  def self.flush_cached_responses
    screenshot_files.map do |last_run|
      FileUtils.rm(last_run)
    end

    # CircleCI task w3c validation depends on this path
    w3c_files_to_validates.map do |last_run|
      FileUtils.rm(last_run)
    end
  end

  def self.run
    puts "running w3c validation with: java -jar node_modules/vnu-jar/build/dist/vnu.jar --errors-only \n#{w3c_files_to_validates.join("\n")}"
    `java -jar node_modules/vnu-jar/build/dist/vnu.jar --errors-only #{W3C_RESPONSE_STORED_DIR.to_s}/*.html`
  end

  def run_request_and_cache_response(report_as:)
    yield
    basename = report_as.parameterize
    ext = '.html'
    assert_equal 1, page.all('.content').size

    File.open(W3C_RESPONSE_STORED_DIR.join("#{basename}#{ext}"), 'w+') do |fd|
      fd.write("<!DOCTYPE html>")
      fd.write(page.body)
      if ENV.has_key?('FUNCTIONAL_SCREENSHOTS')
        page.save_screenshot(SCREENSHOT_DIR.join("#{basename}.png"), full: true)
      end
      assert page_title_ok?(page.body)
    end
    screenshot_full_page("#{basename}.png")
  end

  def screenshot_full_page(screenshot_path)
    return if ENV['CI']
    initial_size = page.driver.browser.manage.window.size
    width = initial_size.width
    height = page.evaluate_script('document.body.scrollHeight')

    page.driver.browser.manage.window.resize_to(initial_size.width, height)

    page.save_screenshot(SCREENSHOT_STORED_DIR.join(screenshot_path))

    page.driver.browser.manage.window.resize_to(initial_size.width, initial_size.height)
  end

  def page_title_ok?(data)
    titles_array = data.match(/<title>(.*)<\/title>/).captures
    return false if titles_array.count > 1
    return false if titles_array.first == 'Monstage'

    true
  end
end
