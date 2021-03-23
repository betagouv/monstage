# frozen_string_literal: true

require 'fileutils'

module Html5Validator
  PA11Y_CONFIG_FILE_NAME = 'pa11y-std-config.json'
  # config possibilities to have from 
  # https://github.com/pa11y/pa11y-ci and
  # rules with htmlcs : https://github.com/pa11y/pa11y/wiki/HTML-CodeSniffer-Rules
  PA11Y_CONFIG_DIR = Rails.root.join('infra', 'test')
  PA11Y_EXE = "./node_modules/pa11y-ci/bin/pa11y-ci.js"
  A11Y_ERROR_DIRECTORY = Rails.root.join('tmp', 'test_results', 'a11y')
  RESPONSE_STORED_DIR = Rails.root.join('tmp', 'w3c')

  def self.flush_cached_responses
    # CircleCI task w3c validation depends on this path
    flush_directory(dir: RESPONSE_STORED_DIR)
  end

  def self.flush_pa11y_error_files
    if Dir.exist?(A11Y_ERROR_DIRECTORY)
      flush_directory(dir: A11Y_ERROR_DIRECTORY)
    else
      FileUtils.mkdir_p A11Y_ERROR_DIRECTORY
    end
  end

  def self.flush_directory(dir: )
    Dir["#{dir}/*"].map do |last_run|
      FileUtils.rm(last_run)
    end
  end

  def self.run
    puts "running w3c validation with: java -jar node_modules/vnu-jar/build/dist/vnu.jar --errors-only \n#{Dir["#{RESPONSE_STORED_DIR}/*"].join("\n")}"
    `java -jar node_modules/vnu-jar/build/dist/vnu.jar --errors-only #{RESPONSE_STORED_DIR.to_s}/*.html`
  end

  def run_request_and_cache_response(report_as:)
    yield
    basename = report_as.parameterize
    ext = '.html'
    assert_equal 1, page.all('.content').size
    # Page context is alive ar this point, and it will not be anymore
    # when file is written
    Html5Validator.pa11y_test(path: self.current_path) if Rails.env.test?

    File.open(RESPONSE_STORED_DIR.join("#{basename}#{ext}"), 'w+') do |fd|
      fd.write("<!DOCTYPE html>")
      fd.write(page.body)
      assert page_title_ok?(data: page.body)
    end
  end

  def page_title_ok?(data:)
    titles_array = data.match(/<title>(.*)<\/title>/).captures
    return false if titles_array.count > 1
    return false if titles_array.first == 'Monstage'

    true
  end

  def self.pa11y_test(path:)
    url = "http://localhost:3000#{path}"
    pa11y_command = "#{PA11Y_EXE} #{url} --config=#{PA11Y_CONFIG_DIR}/#{PA11Y_CONFIG_FILE_NAME}"

    target_file = a11y_error_file_path(file: path)
    test_result = system "#{pa11y_command} >> #{target_file} 2>&1"
    File.delete(target_file) if test_result
  end

  def self.a11y_error_file_path(file:)
    file_name = file.gsub(/\//,'_')[1..-1]
    file_name = 'root' if file_name.blank?
    "/#{A11Y_ERROR_DIRECTORY}/#{file_name}.log"
  end
end
