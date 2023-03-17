require "test_helper"

class IdentitiesControllerTest < ActionDispatch::IntegrationTest
 
  test 'POST #create as student redirects to sign_up page with identity created' do
    student = create(:student_with_class_room_3e)
    student_params = {
      first_name: 'Joe',
      last_name: 'Don',
      birth_date: '2000-01-01',
      gender: 'm',
      school_id: student.school.id,
      class_room_id: student.class_room.id
    }
    assert_difference('Identity.count', 1) do
      post identities_path(identity: student_params)
    end
    identity = Identity.last
    assert_redirected_to "/utilisateurs/inscription?as=Student&identity_token=#{identity.token}"
    follow_redirect!
    assert_select 'span#alert-text',  { text: 'Informations bien enregistrées' }, 1
  end
  
  test 'POST #create as student with missing school params does not create identity' do
    student = create(:student_with_class_room_3e)
    student_params = {
      first_name: 'Joe',
      last_name: 'Don',
      birth_date: '2000-01-01',
      gender: 'm',
      class_room_id: student.class_room.id
    }
    assert_difference('Identity.count', 0) do
      post identities_path(identity: student_params)
    end
  end

end
