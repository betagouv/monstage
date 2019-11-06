class AnonymizeUserJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  # @warning: sometimes it fails ; surprising,
  # try to empty deliveries before running the spec
  setup { ActionMailer::Base.deliveries = [] }
  teardown { ActionMailer::Base.deliveries = [] }

  test 'send email' do
    AnonymizeUserJob.perform_now(recipient_email: 'fourcade.m@gmail.com')
    assert_emails 1
  end
end
