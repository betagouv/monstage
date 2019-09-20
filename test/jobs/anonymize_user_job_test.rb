class AnonymizeUserJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test 'send email' do
    AnonymizeUserJob.perform_now(recipient_email: 'fourcade.m@gmail.com')
    assert_emails 1
  end
end
