require "test_helper"

class RemoteUserActivityTest < ActiveSupport::TestCase
  test 'factory should create user activity' do
    assert build(:remote_user_activity).valid?
  end

  test '#anonymize should anonymize user activity' do
    api_offer = create(:api_internship_offer)
    activity = create(:remote_user_activity, internship_offer: api_offer)
    assert_equal api_offer.id, activity.internship_offer_id
    activity.anonymize
    assert_nil activity.student_id
    assert_nil activity.operator_id
    assert_nil activity.internship_offer_id
  end
end
