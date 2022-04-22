require "test_helper"

class NewsletterControllerTest < ActionDispatch::IntegrationTest
  test "post should not subscribe when email is faulty" do
    test_email = 'test@free@.fr'

    post newsletter_path, params: {newsletter_email: test_email}
    assert_redirected_to root_path
    assert_equal "Votre email a l'air erroné", flash[:warning]
  end

  test "post should subscribe" do
    test_email = 'test@free.fr'
    expected_result = ["S9Dm", "2022-04-17T14:57:56Z", "2022-04-17T14:57:56Z", test_email, ""]

    Services::SyncEmailCampaigns.stub_any_instance(:add_contact, expected_result) do
      post newsletter_path, params: {newsletter_email: test_email}
      assert_redirected_to root_path
      assert_equal 'Votre email a bien été enregistré', flash[:notice]
    end
  end
  
  test "post should not subscribe when already subcribed" do
    test_email = 'test@free.fr'
    expected_result = :previously_existing_email

    Services::SyncEmailCampaigns.stub_any_instance(:add_contact, expected_result) do
      post newsletter_path, params: {newsletter_email: test_email}
      assert_redirected_to root_path
      assert_equal 'Votre email était déjà enregistré. :-) .', flash[:warning]
    end
  end

  test "post should not subscribe when api is faulty" do
    test_email = 'test@free.fr'
    expected_result = "not expected"

    Services::SyncEmailCampaigns.stub_any_instance(:add_contact, expected_result) do
      post newsletter_path, params: {newsletter_email: test_email}
      assert_redirected_to root_path
      err_message = "Une erreur s'est produite et nous n'avons pas " \
                  "pu enregistrer votre email"
      assert_equal err_message, flash[:warning]
    end
  end
end
