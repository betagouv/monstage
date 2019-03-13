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
    employer = create(:employer)
    ability = Ability.new(employer)
    assert(ability.can?(:create, InternshipOffer.new),
           'employers should be able to create internships')
    assert(ability.cannot?(:update, InternshipOffer.new),
           'employers should not be able to update internship offer not belonging to him')
    assert(ability.can?(:update, InternshipOffer.new(employer: employer)),
           'employers should be able to update internships offer that belongs to him')
    assert(ability.cannot?(:destroy, InternshipOffer.new),
           'employers should be able to destroy internships offer not belonging to him')
    assert(ability.can?(:destroy, InternshipOffer.new(employer: employer)),
           'employers should be able to destroy internships offer that belongs to him')
  end

  test "God" do
    ability = Ability.new(create(:god))
    assert(ability.can?(:show, :account),
           'god should be able to see his account')
    assert(ability.can?(:manage, School),
           'god should be able to manage school')
    assert(ability.cannot?(:edit, User),
           'god should not be able to edit user')
  end
end
