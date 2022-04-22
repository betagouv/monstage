
require 'test_helper'

class EmailUtilsTest < ActiveSupport::TestCase
  test '.env_host' do
    # This test is supposed to be ran on test env
    local_host = ENV['HOST']

    ENV['HOST'] = nil
    assert_equal  "https://www.monstagedetroisieme.fr", EmailUtils.env_host

    ENV['HOST'] = 'https://review.example.com'
    assert_equal  "https://review.example.com", EmailUtils.env_host

    ENV['HOST'] = local_host
  end

  test '.domain' do
    local_host = ENV.fetch('HOST')

    if Rails.env.development?
      assert_equal  "localhost", EmailUtils.domain
    end

    ENV['HOST'] = "https://v2-test.monstagedetroiseme.fr"
    assert_equal  "monstagedetroiseme.fr", EmailUtils.domain

    ENV['HOST'] = "https://www.monstagedetroiseme.fr"
    assert_equal  "monstagedetroiseme.fr", EmailUtils.domain

    ENV['HOST'] = nil
    assert_equal  "monstagedetroisieme.fr", EmailUtils.domain

    ENV['HOST'] = local_host
  end

  test '.formatted_email' do
    assert_equal "Mon Stage de 3e <support@#{EmailUtils.domain}>",
                 EmailUtils.formatted_email
  end
end

