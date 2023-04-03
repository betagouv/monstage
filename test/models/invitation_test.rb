require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  test '#save' do
    school_manager = create(:school_manager)
    params = {
      first_name: 'Pablo',
      last_name: 'Picasso',
      email: 'pablo@ac-paris.fr',
      user_id: school_manager.id,
      role: 'teacher'
    }
    invitation = Invitation.new(params)
    assert invitation.valid?
    invitation.save!
    assert_equal 'Pablo', invitation.first_name
    assert_equal 'Picasso', invitation.last_name
    assert_equal 'pablo@ac-paris.fr', invitation.email
    assert_equal 'teacher', invitation.role
    assert_equal school_manager.id, invitation.user_id
  end

  test '#save when missing parameter first_name' do
    school_manager = create(:school_manager)
    params = {
      last_name: 'Pablo',
      email: 'pablo@ac-paris.fr',
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
      email: 'pablo@ac-paris.fr',
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
      email: 'pabloac-paris.fr',
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
      email:'pablo@ac-paris.fr',
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
      email: 'pablo@ac-paris.fr',
      role: 'teacher'
    }
    invitation = Invitation.new(params)
    refute invitation.valid?
  end
end
