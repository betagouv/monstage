require "test_helper"

class SignatureTest < ActiveSupport::TestCase

  test 'factory' do
    signature = build(:signature)
    assert signature.valid?
    assert signature.save
  end

  test 'signatures_count scope' do
    assert_equal 0, Signature.signatures(internship_agreement_id: 1).count
    signature = create(:signature)
    assert_equal 1, Signature.signatures(internship_agreement_id: signature.internship_agreement_id).count
    assert_equal 1, signature.signatures_count
  end

  test 'all_signed? scope' do
    signature = create(:signature, :employer_signature)
    refute  signature.all_signed?
    create(:signature, :school_manager_signature, internship_agreement_id: signature.internship_agreement_id)
    assert signature.all_signed?
  end

  test 'double_signature? validates' do
    signature = create(:signature, :employer_signature)
    other_signature = build(:signature, :employer_signature, internship_agreement_id: signature.internship_agreement_id)
    refute other_signature.valid?
    another_signature = build(:signature, :school_manager_signature, internship_agreement_id: signature.internship_agreement_id)
    assert another_signature.valid?
  end

  test '.roles_already_signed scope' do
    signature = create(:signature, :employer_signature)
    assert_equal ["employer"], Signature.roles_already_signed(internship_agreement_id: signature.internship_agreement_id)
    create(:signature, :school_manager_signature, internship_agreement_id: signature.internship_agreement_id)
    assert_equal ["employer","school_manager"], Signature.roles_already_signed(internship_agreement_id: signature.internship_agreement_id)
  end

  test '.already_signed? scope' do
    signature = create(:signature, :employer_signature)
    assert  Signature.already_signed?(user_role: :employer,
                                      internship_agreement_id: signature.internship_agreement_id)
    create(:signature,
           :school_manager_signature,
           internship_agreement_id: signature.internship_agreement_id
     )
    assert Signature.already_signed?(user_role: :school_manager,
                                     internship_agreement_id: signature.internship_agreement_id)
  end

  test '.missing_signatures scope' do
    signature = create(:signature, :employer_signature)
    assert_equal ["school_manager"], Signature.missing_signatures(internship_agreement_id: signature.internship_agreement_id)
    create(:signature, :school_manager_signature, internship_agreement_id: signature.internship_agreement_id)
    assert_equal [], Signature.missing_signatures(internship_agreement_id: signature.internship_agreement_id)
  end
end
