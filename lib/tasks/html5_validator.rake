# frozen_string_literal: true

namespace :html5_validator do
  desc 'each run of test generates html files for validation, ' \
       'cleanup previous generated files'
  task flush_cached_responses: :environment do
    puts 'run flush_cached_responses'
    Html5Validator.flush_cached_responses
  end

  task flush_pa11y_error_files: :environment do
    puts 'run flush_pa11y_error_files'
    Html5Validator.flush_pa11y_error_files
  end

  desc 'run html5 validation on generated files from test'
  task run: :environment do
    puts 'run Html5Validator.run'
    Html5Validator.run
  end
end
