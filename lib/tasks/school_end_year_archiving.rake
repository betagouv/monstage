# frozen_string_literal: true
require 'pretty_console.rb'

desc "School is over. Let's clean and prepare next year"
task school_end_year_archiving: :environment do
  ActiveRecord::Base.transaction do
    Users::Student.kept
                  .find_each do |student|
      student.archive
    end
  end

  PrettyConsole.say_in_green 'All students are archived.'
end
