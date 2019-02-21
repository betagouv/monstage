require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  test "MockUser::Visitor" do
    ability = Ability.new(MockUser::Student)
    assert(ability.can?(:read, InternshipOffer.new),
           'visitors should be able to consult internships')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'visitors should not be able to con manage internships')
  end

  test "MockUser::Student" do
    ability = Ability.new(MockUser::Visitor)
    assert(ability.can?(:read, InternshipOffer.new),
           'visitors should be able to consult internship offers')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'visitors should not be able to con manage internships')
  end

  test "MockUser::Employer" do
    ability = Ability.new(MockUser::Employer)
    assert(ability.can?(:manage, InternshipOffer.new),
           'employers should be able to manage internships')
  end
end
