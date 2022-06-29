require 'test_helper'

class InternshipAgreementTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert build(:internship_agreement).valid?
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
end
