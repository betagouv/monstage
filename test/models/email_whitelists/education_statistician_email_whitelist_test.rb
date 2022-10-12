# frozen_string_literal: true

require 'test_helper'

class EducationStatisticianEmailWhitelistTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'send email after create' do
    assert_enqueued_emails 1 do
      create(:education_statistician_email_whitelist, email: 'dasen@departement60-educ-nat.fr', zipcode: '60')
    end
  end

  test 'destroy email whitelist also discard education statistician' do
    statistician = create(:education_statistician)
    email_whitelist = create(:education_statistician_email_whitelist, email: statistician.email, user: statistician, zipcode: 60)
    freeze_time do
      assert_changes(-> { statistician.reload.discarded_at.try(:utc) },
                     from: nil,
                     to: Time.now.utc) do
        email_whitelist.destroy!
      end
    end
  end
end
