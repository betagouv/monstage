# frozen_string_literal: true

namespace :html5_validator do
  desc 'each run of test generates html files for validation, ' \
       'cleanup previous generated files'
  task flush_cached_responses: :environment do
    puts 'run flush_cached_responses'
    Html5Validator.flush_cached_responses
  end

  desc 'run html5 validation on generated files from test'
  task run: :environment do
    puts 'run Html5Validator.run'
    Html5Validator.run
  end

  desc 'run all of w3c tests and adds functional screenshots from test'
  task run_with_screenshots: :environment do
    puts 'run Html5Validator.run with screenshots'
    system 'FUNCTIONAL_SCREENSHOTS=true ./infra/test/w3c.sh'
  end
end
