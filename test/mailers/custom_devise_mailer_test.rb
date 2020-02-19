# frozen_string_literal: true

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
      if user.is_a?(Users::Student) || user.is_a?(Users::MainTeacher)
        assert(email.attachments
                    .map(&:filename)
                    .include?('autorisation-parentale.pdf'))
      else
        assert(email.body.decoded.include?('Bienvenue'),
               "bad body for #{user.type}")
      end
    end
  end

  test '.confirmation_instructions with unconfirmed_email change wording' do
    employer = create(:employer)
    employer.update!(email: 'nouvel@ema.le')
    email = CustomDeviseMailer.confirmation_instructions(employer, SecureRandom.hex)
    assert email.body.decoded.include?("Bonjour, nous venons de recevoir une demande de changement d'Adresse électronique (e-mail) pour votre compte monstagedetroisieme.fr.")
  end
end
