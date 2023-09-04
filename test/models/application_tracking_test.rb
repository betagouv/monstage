require "test_helper"

class ApplicationTrackingTest < ActiveSupport::TestCase
  test "should create application tracking" do
    application_tracking = build(:application_tracking)
    assert application_tracking.valid?
    assert application_tracking.save
  end
end
