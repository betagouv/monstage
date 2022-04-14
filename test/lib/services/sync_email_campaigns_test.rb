require 'test_helper'

module Services
  class SyncEmailCampaignsTest < ActiveSupport::TestCase
    test 'add_contact should destroy contact when contact does exist' do
      expected_result = { "result" => "ok" }
      user = User.new(email: 'test@free.fr')
      sync = Services::SyncEmailCampaigns.new
      list_name_hash = { list_name: 'test' }

      fake_fetch_list_id = Minitest::Mock.new
      fake_fetch_list_id.expect :call,
                                42,
                                [ { list_name: 'newsletter' }]
      fake_search_contact_by_email = Minitest::Mock.new
      fake_search_contact_by_email.expect :call,
                                           nil,
                                           [{email: user.email, list_name: 'newsletter'}]
      fake_add_contact_to_list = Minitest::Mock.new
      fake_add_contact_to_list.expect :call,
                                      OpenStruct.new(code: 200, body: expected_result.to_json),
                                      [{user: user, list_id: 42}]


      sync.stub :fetch_list_id, fake_fetch_list_id do
        sync.stub :search_contact_by_email, fake_search_contact_by_email do
          sync.stub :add_contact_to_list, fake_add_contact_to_list do
            assert_equal expected_result, sync.add_contact(user: user)
          end
        end
      end
    end

    test 'add_contact should not destroy contact when contact does not exist' do
      user = User.new(email: 'test@free.fr')
      sync = Services::SyncEmailCampaigns.new
      list_name_hash = { list_name: 'test' }

      fake_fetch_list_id = Minitest::Mock.new
      fake_fetch_list_id.expect :call,
                                42,
                                [{ list_name: 'newsletter' }]

      fake_search_contact_by_email = Minitest::Mock.new
      fake_search_contact_by_email.expect :call,
                                          "something",
                                          [{email: user.email, list_name: 'newsletter'}]

      sync.stub :fetch_list_id, fake_fetch_list_id do
        sync.stub :search_contact_by_email, fake_search_contact_by_email do
            assert_equal :previously_existing_email, sync.add_contact(user: user)
        end
      end
    end
  end
end