require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  test '#save' do
    school_manager = create(:school_manager)
    params = {
      first_name: 'Pablo',
      last_name: 'Picasso',
      email: 'pablo@heavens.com',
      user_id: school_manager.id,
      role: 'teacher'
    }
    invitation = Invitation.new(params)
    assert invitation.valid?
    invitation.save!
    assert_equal 'Pablo', invitation.first_name
    assert_equal 'Picasso', invitation.last_name
    assert_equal 'pablo@heavens.com', invitation.email
    assert_equal 'teacher', invitation.role
    assert_equal school_manager.id, invitation.user_id
  end

  test '#save when missing parameter first_name' do
    school_manager = create(:school_manager)
    params = {
      last_name: 'Pablo',
      email: 'pablo@heavens.com',
      user_id: school_manager.id,
      role: 'teacher'
    }
    invitation = Invitation.new(params)
    refute invitation.valid?
  end

  test '#save when missing parameter last_name' do
    school_manager = create(:school_manager)
    params = {
      first_name: 'Pablo',
      email: 'pablo@heavens.com',
      user_id: school_manager.id,
      role: 'teacher'
    }
    invitation = Invitation.new(params)
    refute invitation.valid?
  end

  test '#save when missing parameter email' do
    school_manager = create(:school_manager)
    params = {
      first_name: 'Pablo',
      last_name: 'Picasso',
      user_id: school_manager.id,
      role: 'teacher'
    }
    invitation = Invitation.new(params)
    refute invitation.valid?
  end

  test '#save with faulty parameter email' do
    school_manager = create(:school_manager)
    params = {
      first_name: 'Pablo',
      last_name: 'Picasso',
      email: 'pabloheavens.com',
      user_id: school_manager.id,
      role: 'teacher'
    }
    invitation = Invitation.new(params)
    refute invitation.valid?
  end

  test '#save when missing parameter role' do
    school_manager = create(:school_manager)
    params = {
      first_name: 'Pablo',
      last_name: 'Picasso',
      email:'pablo@heavens.com',
      user_id: school_manager.id
    }
    invitation = Invitation.new(params)
    refute invitation.valid?
  end

  test '#save when missing parameter user_id' do
    school_manager = create(:school_manager)
    params = {
      first_name: 'Pablo',
      last_name: 'Picasso',
      email: 'pablo@heavens.com',
      role: 'teacher'
    }
    invitation = Invitation.new(params)
    refute invitation.valid?
  end
end
