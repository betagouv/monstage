# frozen_string_literal: true

class HostingInfoWeek < ApplicationRecord
  include Weekable
  belongs_to :hosting_info, counter_cache: true

  delegate :max_candidates, to: :hosting_info
  delegate :max_students_per_group, to: :hosting_info
end
