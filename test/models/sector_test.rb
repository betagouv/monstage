# frozen_string_literal: true

require 'test_helper'

class SectorTest < ActiveSupport::TestCase
  test 'create set uuid' do
    assert_not_nil Sector.create(name: 'hello').uuid
  end
end
