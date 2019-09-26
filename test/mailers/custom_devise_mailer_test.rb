require 'test_helper'

class CustomDeviseMailerTest < ActionMailer::TestCase
  test '.confirmation_instructions attaches authorisation-parentale.pdf' \
       ' for students & main_teachers' do
    school = create(:school)
    email = "bing@bongo.bang"
    create(:email_whitelist, email: email, zipcode: '60')

    school_manager = create(:school_manager, school: school)
    roles = [ create(:employer),
              create(:god),
              create(:main_teacher, school: school),
              create(:user_operator),
              create(:other, school: school),
              create(:statistician, email: email),
              create(:student),
              create(:teacher, school: school) ]
    (roles + [school_manager]).each do |user|
      email = CustomDeviseMailer.confirmation_instructions(user, SecureRandom.hex)
      assert_equal(user.is_a?(Users::Student) || user.is_a?(Users::MainTeacher),
                   email.attachments
                        .map(&:filename)
                        .include?('authorisation-parentale.pdf'))
    end
  end
end
