# frozen_string_literal: true

require 'test_helper'

class EmailWhitelistTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'send email after create' do
    assert_enqueued_emails 1 do
      create(:email_whitelist, email: 'kikoo@lol.fr')
    end
  end
end
