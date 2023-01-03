# frozen_string_literal: true

require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  test 'Agreements association' do
    school = create(:school, :with_agreement_presets, :with_school_manager)
    student = create(:student_with_class_room_3e, school: school)
    internship_application = create(:weekly_internship_application, user_id: student.id)
    internship_agreement = create(:internship_agreement, :created_by_system,
                                  internship_application: internship_application)
    internship_agreement_presets = school.internship_agreement_preset

    assert internship_agreement_presets.internship_agreements.include?(internship_agreement)
  end

  test 'set school_delegation_to_sign_delivered_at first time populates internship_agreements created by system' do
    school = create(:school, :with_agreement_presets_missing_date, :with_school_manager)
    student = create(:student_with_class_room_3e, school: school)
    internship_application = create(:weekly_internship_application, user_id: student.id)
    internship_agreement = create(:internship_agreement, :created_by_system,
                                  internship_application: internship_application)
    internship_agreement_presets = school.internship_agreement_preset
    new_date = 3.weeks.ago.to_date
    assert_changes -> { internship_agreement.reload.school_delegation_to_sign_delivered_at },
                   from: nil,
                   to: new_date do
      internship_agreement_presets.update(school_delegation_to_sign_delivered_at: new_date)
    end

    new_date = 4.weeks.ago.to_date
    assert_no_changes -> { internship_agreement.reload.school_delegation_to_sign_delivered_at } do
      internship_agreement_presets.update(school_delegation_to_sign_delivered_at: new_date)
    end
  end
end
