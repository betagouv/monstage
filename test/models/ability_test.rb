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
    assert(ability.can?(:apply, InternshipOffer.new),
           'visitors should be able to apply for internship offers')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'visitors should not be able to con manage internships')
  end

  test "MockUser::Employer" do
    ability = Ability.new(MockUser::Employer)
    assert(ability.can?(:create, InternshipOffer.new),
           'employers should be able to create internships')
    assert(ability.can?(:update, InternshipOffer.new),
           'employers should be able to update internships')
    assert(ability.can?(:desctroy, InternshipOffer.new),
           'employers should be able to destroy internships')
  end
end
