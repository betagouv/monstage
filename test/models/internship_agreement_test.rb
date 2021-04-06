require 'test_helper'

class InternshipAgreementTest < ActiveSupport::TestCase
  test "validates school_track" do
    internship_agreement = InternshipAgreement.new(school_track: nil)
    internship_agreement.valid?
    assert internship_agreement.errors.include?(:school_track)
  end

  test 'skip validation of fields with when school_track is troisieme_generale' do
    internship_agreement = InternshipAgreement.new(school_track: :troisieme_generale)
    internship_agreement.valid?
  end

  test 'ensure presence fields when school_manager and not 3e' do
    internship_agreement = InternshipAgreement.new(school_track: :troisieme_prepa_metiers,
                                                   enforce_school_manager_validations: true)
    internship_agreement.valid?

    assert internship_agreement.errors.include?(:activity_rating_rich_text)
    assert internship_agreement.errors.include?(:complementary_terms_rich_text)
  end

  test 'ensure presence of fields when employer and not 3e' do
    internship_agreement = InternshipAgreement.new(school_track: :troisieme_prepa_metiers,
                                                   enforce_employer_validations: true)
    internship_agreement.valid?

    assert internship_agreement.errors.include?(:activity_learnings_rich_text)
    assert internship_agreement.errors.include?(:activity_scope_rich_text)
    assert internship_agreement.errors.include?(:complementary_terms_rich_text)
  end

  test 'ensure presence of fields when main_teacher and not 3e' do
    internship_agreement = InternshipAgreement.new(school_track: :troisieme_prepa_metiers,
                                                   enforce_main_teacher_validations: true)
    internship_agreement.valid?

    assert internship_agreement.errors.include?(:activity_preparation_rich_text)
  end
end
