# frozen_string_literal: true

task test: 'html5_validator:flush_cached_responses'
namespace :test do
  desc 'Run both regular tests and system tests'
  task w3c: 'test' do
    Minitest.after_run { Html5Validator.run }
  end
end
