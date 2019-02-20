require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  test "User::Visitor" do
    ability = Ability.new(User::Student)
    assert(ability.can?(:read, InternshipOffer.new),
           'visitors should be able to consult internships')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'visitors should not be able to con manage internships')
  end

  test "User::Student" do
    ability = Ability.new(User::Visitor)
    assert(ability.can?(:read, InternshipOffer.new),
           'visitors should be able to consult internship offers')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'visitors should not be able to con manage internships')
  end

  test "User::Employer" do
    ability = Ability.new(User::Employer)
    assert(ability.can?(:manage, InternshipOffer.new),
           'employers should be able to manage internships')
  end
end
