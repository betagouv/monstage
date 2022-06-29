require "test_helper"

class SignatureTest < ActiveSupport::TestCase

  test 'factory' do
    signature = build(:signature)
    assert signature.valid?
    assert signature.save
  end

  test 'signatures_count' do
    signature = create(:signature)
    assert_equal 1, signature.signatures_count
  end

  test 'all_signed?' do
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
end
