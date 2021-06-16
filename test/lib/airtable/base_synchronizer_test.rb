# frozen_string_literal: true

require 'test_helper'
module Airtable
  class BaseSynchronizerTest < ActiveSupport::TestCase
    test '.pull_all' do
      operator = create(:operator,
                        name: Operator::AIRTABLE_CREDENTIAL_MAP.keys.first,
                        airtable_reporting_enabled: true)

      Operator.stub :reportable, [operator] do
        mock = Minitest::Mock.new
        mock.expect(:pull_all, true, [])
        Airtable::TableSynchronizer.stub(:new, mock) do
          Airtable::BaseSynchronizer.new.pull_all
        end
        mock.verify
      end

    end
  end
end
