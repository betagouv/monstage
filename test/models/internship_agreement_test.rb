require 'test_helper'
require 'pretty_console.rb'

class InternshipAgreementTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert build(:internship_agreement).valid?
  end

  test '#roles_not_signed_yet' do
    internship_agreement = create(:internship_agreement, aasm_state: :validated)
    assert_equal ['school_manager', 'employer'],
                 internship_agreement.roles_not_signed_yet
    create(:signature,
           signatory_role: :school_manager,
           internship_agreement_id: internship_agreement.id)
    assert_equal ['employer'],
                  internship_agreement.roles_not_signed_yet
  end

  test '#notify_others_signatures_finished' do
    internship_agreement = create(:internship_agreement, aasm_state: :validated)
    create(:signature,
           signatory_role: :school_manager,
           internship_agreement_id: internship_agreement.id)
  end

  test '#every_signature_but_mine' do
    internship_agreement = create(:internship_agreement, aasm_state: :validated)
    sign1 = create(:signature,
                    signatory_role: :school_manager,
                    internship_agreement_id: internship_agreement.id)
    internship_agreement.sign!
    create(:signature, signatory_role: :employer,
                       internship_agreement_id: internship_agreement.id)
    assert_equal [sign1],internship_agreement.send(:every_signature_but_mine)
  end

  test '#ready_to_sign?' do
    internship_agreement = create(:internship_agreement, aasm_state: :validated)
    assert internship_agreement.ready_to_sign?(user: internship_agreement.school_manager)
    create(:signature,
           :school_manager,
           internship_agreement_id: internship_agreement.id)

    refute internship_agreement.ready_to_sign?(user: internship_agreement.school_manager)
    assert internship_agreement.ready_to_sign?(user: internship_agreement.employer)

    create(:signature,
      :employer,
      internship_agreement_id: internship_agreement.id)

    refute internship_agreement.ready_to_sign?(user: internship_agreement.employer)

    internship_agreement_2 = create(:internship_agreement, aasm_state: :signed_by_all)
    refute internship_agreement_2.ready_to_sign?(user: internship_agreement_2.school_manager)
  end

  test '#signed_by? starting with school_manager' do
    internship_agreement = create(:internship_agreement, aasm_state: :validated)
    refute internship_agreement.signed_by?(user: internship_agreement.school_manager)
    create(:signature, :school_manager,
            internship_agreement_id: internship_agreement.id)
    assert internship_agreement.signed_by?(user: internship_agreement.school_manager)
    refute internship_agreement.signed_by?(user: internship_agreement.employer)
  end

  test '#signed_by? starting with employer' do
    internship_agreement = create(:internship_agreement, aasm_state: :validated)
    refute internship_agreement.signed_by?(user: internship_agreement.employer)
    create(:signature, :employer,
            internship_agreement_id: internship_agreement.id)
    assert internship_agreement.signed_by?(user: internship_agreement.employer)
    refute internship_agreement.signed_by?(user: internship_agreement.school_manager)
  end

  test "validates school_track" do
    internship_agreement = InternshipAgreement.new(school_track: nil)
    internship_agreement.valid?
    assert internship_agreement.errors.include?(:school_track)
  end

  test 'skip validation of fields with when school_track is troisieme_generale' do
    internship_agreement = InternshipAgreement.new(school_track: :troisieme_generale)
    internship_agreement.valid?
  end
  test 'factory' do
    internship_agreement = build(:internship_agreement)
    assert internship_agreement.valid?
    assert internship_agreement.save!
  end
end
