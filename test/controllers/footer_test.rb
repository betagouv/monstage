# frozen_string_literal: true

require 'test_helper'

class FooterTest < ActionDispatch::IntegrationTest
  include ThirdPartyTestHelpers

  test 'presence of footer links within valid rg2a footer' do
    prismic_root_path_stubbing do
      get root_path

      assert_select('a[href=?]',
                    'https://beta.gouv.fr/startups/monstage.html')
      assert_select('a[href=?]', mentions_legales_path)
      assert_select('a[href=?]', conditions_d_utilisation_path)
      assert_select('a[href=?]', accessibilite_path)
      assert_select('a[href=?]', accessibilite_path)

    end
  end
end
