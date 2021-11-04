# frozen_string_literal: true

require 'test_helper'
class OperatorTest < ActiveSupport::TestCase

  test 'airtable_table' do
    operator = build(:operator, name: Operator::AIRTABLE_CREDENTIAL_MAP.keys.first)
    assert_not_nil operator.airtable_table

  end

  test 'airtable_app_id' do    
    operator = build(:operator, name: Operator::AIRTABLE_CREDENTIAL_MAP.keys.first)
    assert_not_nil operator.airtable_app_id
  end

end
