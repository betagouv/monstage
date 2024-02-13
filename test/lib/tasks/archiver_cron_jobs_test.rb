
require 'test_helper'

class ArchiverCronJobsTest < ActiveSupport::TestCase
  test 'archive too old current_sign_in_at or teacher without school' do
    teacher = create(:teacher)
    create(:teacher, last_sign_in_at: 3.years.ago, current_sign_in_at: Date.today - 2.years- 10.minutes)
    teacher.update_columns(class_room_id: nil, school_id: nil)
    assert_equal 2, Users::SchoolManagement.kept.reload.count
    Monstage::Application.load_tasks
    Rake::Task['cleaning:confidentiality_cleaning'].invoke 
    assert_equal 0, Users::SchoolManagement.kept.reload.count
  end
end