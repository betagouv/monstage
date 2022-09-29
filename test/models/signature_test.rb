require "test_helper"

class SignatureTest < ActiveSupport::TestCase

  test 'factory' do
    signature = build(:signature, :employer)
    assert signature.valid?
    assert signature.save
    assert_equal signature.user_id, Signature.last.employer.id

    signature = build(:signature, :school_manager)
    assert signature.valid?
    assert signature.save
    assert_equal signature.user_id, Signature.last.school_manager.id
  end

  test 'signatures_count' do
    signature = create(:signature ,:employer)
    assert_equal 1, signature.signatures_count
  end

  test 'all_signed?' do
    signature = create(:signature, :employer)
    refute  signature.all_signed?
    create(:signature, :school_manager, internship_agreement_id: signature.internship_agreement_id)
    assert signature.all_signed?
  end

  test 'double_signature? validates' do
    signature = create(:signature, :employer)
    other_signature = build(:signature, :employer, internship_agreement_id: signature.internship_agreement_id)
    refute other_signature.valid?
    another_signature = build(:signature, :school_manager, internship_agreement_id: signature.internship_agreement_id)
    assert another_signature.valid?
  end

  test '#file_path' do
    signature = create(:signature, :employer)
    expected = "signature_storage/signature-test-employer-#{signature.internship_agreement_id}.png"
    assert_equal expected, signature.local_signature_image_file_path
  end

  test '.file_path' do
    signature = create(:signature, :employer)
    expected = "signature_storage/signature-test-employer-#{signature.internship_agreement_id}.png"
    assert_equal expected,
                 Signature.file_path(user: signature.employer, internship_agreement_id: signature.internship_agreement_id)

    assert_equal Signature.file_path(user: signature.employer, internship_agreement_id: signature.internship_agreement_id),
                 signature.local_signature_image_file_path
  end
end