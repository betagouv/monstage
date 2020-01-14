# frozen_string_literal: true

require 'test_helper'

class ReportingSchoolTest < ActiveSupport::TestCase
  test 'without_school_manager' do
    school_without_manager = create(:school)
    create(:school, school_manager: build(:school_manager))
    create(:school, school_manager: build(:school_manager))

    assert_equal 1, Reporting::School.without_school_manager.entries.size, 1
    assert Reporting::School.without_school_manager.entries.include?(school_without_manager)

    assert_equal 2, Reporting::School.with_school_manager.count, 'bad count for with_school_manager'
    assert_equal 3, Reporting::School.count, 'bad count for total'
  end
end
