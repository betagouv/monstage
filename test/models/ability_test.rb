require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  test "Visitor" do
    ability = Ability.new()
    assert(ability.can?(:read, InternshipOffer.new),
           'visitors should be able to consult internships')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'visitors should not be able to con manage internships')
  end

  test "Student" do
    ability = Ability.new(create(:student))
    assert(ability.can?(:read, InternshipOffer.new),
           'students should be able to consult internship offers')
    assert(ability.can?(:apply, InternshipOffer.new),
           'students should be able to apply for internship offers')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'students should not be able to con manage internships')
  end

  test "Employer" do
    ability = Ability.new(create(:employer))
    assert(ability.can?(:create, InternshipOffer.new),
           'employers should be able to create internships')
    assert(ability.can?(:update, InternshipOffer.new),
           'employers should be able to update internships')
    assert(ability.can?(:destroy, InternshipOffer.new),
           'employers should be able to destroy internships')
  end
end
