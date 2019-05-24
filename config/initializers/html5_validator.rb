# frozen_string_literal: true

require 'fileutils'

module Html5Validator
  RESPONSE_STORED_DIR = Rails.root.join('tmp', 'w3c')

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
    puts "running w3c validation with: \n#{files_to_validates.join("\n")}"
    `java -jar node_modules/vnu-jar/build/dist/vnu.jar --errors-only #{RESPONSE_STORED_DIR.to_s}/*.html`
  end

  def run_request_and_cache_response(report_as:)
    yield
    basename = report_as.parameterize
    ext = '.html'
    raise 'testing page without 200, not possible' if response.status != 200

    File.open(RESPONSE_STORED_DIR.join("#{basename}#{ext}"), 'w+') do |fd|
      fd.write(response.body)
    end
  end
end
