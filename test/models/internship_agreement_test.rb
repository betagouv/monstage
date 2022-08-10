require 'test_helper'
require 'pretty_console.rb'

class InternshipAgreementTest < ActiveSupport::TestCase
  test 'factory' do
    internship_agreement = build(:internship_agreement)
    assert internship_agreement.valid?
    assert internship_agreement.save!
  end
end
