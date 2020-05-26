# frozen_string_literal: true

require 'test_helper'

class ReportingSchoolTest < ActiveSupport::TestCase
  test 'without_school_manager' do
    school_without_manager = create(:school)
    create(:school, :with_school_manager)
    create(:school, :with_school_manager)

    schools_without_manager = Reporting::School.without_school_manager.entries
    assert_equal 1, schools_without_manager.size, 1
    assert schools_without_manager.map(&:id)
                                  .include?(school_without_manager.id)

    assert_equal 3, Reporting::School.count, 'bad count for total'
  end
end
