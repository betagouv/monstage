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
end
