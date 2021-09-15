# frozen_string_literal: true

require 'fileutils'

module Html5Validator
  RESPONSE_STORED_DIR = Rails.root.join('tmp', 'w3c')
  SCREENSHOT_DIR = Rails.root.join('tmp', 'functional_screenshots')

  def self.files_to_validates
    Dir["#{RESPONSE_STORED_DIR}/*"]
  end

  def self.flush_cached_responses
    # CircleCI task w3c validation depends on this path
    files_to_validates.map do |last_run|
      FileUtils.rm(last_run)
    end
  end

  def self.run
    puts "running w3c validation with: java -jar node_modules/vnu-jar/build/dist/vnu.jar --errors-only \n#{files_to_validates.join("\n")}"
    `java -jar node_modules/vnu-jar/build/dist/vnu.jar --errors-only #{RESPONSE_STORED_DIR.to_s}/*.html`
  end

  def run_request_and_cache_response(report_as:)
    yield
    basename = report_as.parameterize
    ext = '.html'
    assert_equal 1, page.all('.content').size

    File.open(RESPONSE_STORED_DIR.join("#{basename}#{ext}"), 'w+') do |fd|
      fd.write("<!DOCTYPE html>")
      fd.write(page.body)
      if ENV.has_key?('FUNCTIONAL_SCREENSHOTS')
        page.save_screenshot(SCREENSHOT_DIR.join("#{basename}.png"), full: true)
      end
      assert page_title_ok?(page.body)
    end
  end

  def page_title_ok?(data)
    titles_array = data.match(/<title>(.*)<\/title>/).captures
    return false if titles_array.count > 1
    return false if titles_array.first == 'Monstage'

    true
  end
end
