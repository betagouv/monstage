require 'test_helper'

module Services
  class SyncEmailCampaignsTest < ActiveSupport::TestCase
    test 'add_contact should destroy contact when contact does exist' do
      expected_result = { "result" => "ok" }
      fake_list_id = 42
      user = User.new(email: 'test@free.fr')
      sync = Services::SyncEmailCampaigns.new
      list_name_hash = { list_name: 'test' }

      fake_fetch_list_id = Minitest::Mock.new
      fake_fetch_list_id.expect :call,
                                fake_list_id,
                                [ { list_name: 'newsletter' }]
      fake_search_result = Minitest::Mock.new
      fake_search_result.expect :call,
                                nil,
                                [{email: user.email, list_id: fake_list_id}]
      fake_add_contact_to_list = Minitest::Mock.new
      fake_add_contact_to_list.expect :call,
                                      OpenStruct.new(code: 200, body: expected_result.to_json),
                                      [{user: user, list_id: 42}]


      sync.stub :fetch_list_id, fake_fetch_list_id do
        sync.stub :search_contact_by_email, fake_search_result do
          sync.stub :add_contact_to_list, fake_add_contact_to_list do
            assert_equal expected_result, sync.add_contact(user: user)
          end
        end
      end
    end

    test 'add_contact should not destroy contact when contact does not exist' do
      user = User.new(email: 'test@free.fr')
      fake_list_id = 42
      sync = Services::SyncEmailCampaigns.new
      list_name_hash = { list_name: 'test' }

      fake_fetch_list_id = Minitest::Mock.new
      fake_fetch_list_id.expect :call,
                                fake_list_id,
                                [{ list_name: 'newsletter' }]

      fake_search_contact_by_email = Minitest::Mock.new
      fake_search_contact_by_email.expect :call,
                                          "something",
                                          [{email: user.email, list_id: fake_list_id}]

      sync.stub :fetch_list_id, fake_fetch_list_id do
        sync.stub :search_contact_by_email, fake_search_contact_by_email do
            assert_equal :previously_existing_email, sync.add_contact(user: user)
        end
      end
    end

    test "remove existing contact should be ok" do
      service = Services::SyncEmailCampaigns
      search_search_result =  ["a" "something"]
      expected_delete_result = OpenStruct.new(code: 200)

      service.stub_any_instance(:fetch_list_id, 42) do
        service.stub_any_instance(:search_contact_by_email, search_search_result) do
          service.stub_any_instance(:delete_contact_from_list, expected_delete_result) do
            assert service.new.remove_contact(email: 'fake@free.fr')
          end
        end
      end
    end

    test "remove contact from inexistant_list should fail" do
      service = Services::SyncEmailCampaigns
      expected_delete_result = OpenStruct.new(code: 200)

      service.stub_any_instance(:fetch_list_id, "") do
        service.stub_any_instance(:search_contact_by_email, nil) do
          service.stub_any_instance(:delete_contact_from_list, expected_delete_result) do
            assert_equal :unexisting_list, service.new.remove_contact(email: 'fake@free.fr')
          end
        end
      end
    end

    test "remove unexisting contact from should fail" do
      service = Services::SyncEmailCampaigns
      expected_delete_result = OpenStruct.new(code: 200)

      service.stub_any_instance(:fetch_list_id, 42) do
        service.stub_any_instance(:search_contact_by_email, nil) do
          service.stub_any_instance(:delete_contact_from_list, expected_delete_result) do
            assert_equal :unexisting_email, service.new.remove_contact(email: 'fake@free.fr')
          end
        end
      end
    end
  end
end