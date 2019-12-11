require 'test_helper'

class CustomDeviseMailerTest < ActionMailer::TestCase
  test '.confirmation_instructions attaches authorisation-parentale.pdf' \
       ' for students & main_teachers' do
    school = create(:school)
    school_manager = create(:school_manager, school: school)
    roles = [ create(:employer),
              create(:god),
              create(:main_teacher, school: school),
              create(:user_operator),
              create(:other, school: school),
              create(:statistician),
              create(:student),
              create(:teacher, school: school) ]
    (roles + [school_manager]).each do |user|
      email = CustomDeviseMailer.confirmation_instructions(user, SecureRandom.hex)
      assert_equal(user.is_a?(Users::Student) || user.is_a?(Users::MainTeacher),
                   email.attachments
                        .map(&:filename)
                        .include?('autorisation-parentale.pdf'))
    end
  end
end
