# frozen_string_literal: true

class InternshipOfferInfoWeek < ApplicationRecord
  include Weekable
  belongs_to :internship_offer_info, counter_cache: true

  delegate :max_candidates, to: :internship_offer_info
end
