require 'test_helper'

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
           signatory_role: :school_manager,
           internship_agreement_id: internship_agreement.id)
    refute internship_agreement.ready_to_sign?(user: internship_agreement.school_manager)

    internship_agreement_2 = create(:internship_agreement, aasm_state: :signed_by_all)
    refute internship_agreement_2.ready_to_sign?(user: internship_agreement_2.school_manager)
  end

  test '#signed_by?' do
    internship_agreement = create(:internship_agreement, aasm_state: :validated)
    refute internship_agreement.signed_by?(user: internship_agreement.school_manager)
    create(:signature, :school_manager,
            internship_agreement_id: internship_agreement.id)
    assert internship_agreement.signed_by?(user: internship_agreement.school_manager)
  end
end
