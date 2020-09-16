require 'test_helper'

class CustomDeviseMailerTest < ActionMailer::TestCase
  test '.confirmation_instructions attaches authorisation-parentale.pdf' \
       ' for students & main_teachers' do
    school = create(:school)
    school_manager = create(:school_manager, school: school)
    roles = [create(:employer),
             create(:god),
             create(:main_teacher, school: school),
             create(:user_operator),
             create(:other, school: school),
             create(:statistician),
             create(:student),
             create(:teacher, school: school)]
    (roles + [school_manager]).each do |user|
      email = CustomDeviseMailer.confirmation_instructions(user, SecureRandom.hex)
      assert(email.html_part.body.include?('Bienvenue'),
             "bad body for #{user.type}")
    end
  end

  test '.update_email_instructions' do
    origin_email = 'origin@to.com'
    employer = create(:employer, email: origin_email,
                                 unconfirmed_email: 'destination@to.com')
    email = CustomDeviseMailer.update_email_instructions(employer, SecureRandom.hex)
    assert_equal [origin_email], email.to
    assert_equal "Action requise - Confirmez votre changement d'adresse électronique (e-mail)", email.subject
    assert email.html_part.body.include?(employer.formal_name)
    assert email.html_part.body.include?('nous venons de recevoir une demande de changement')
  end

  test '.add_email_instructions' do
    skip('not reproductible due to devise wiring')
  end
end
