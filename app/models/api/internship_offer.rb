# frozen_string_literal: true

module Api
  class InternshipOffer < ApplicationRecord
    include Nearbyable
    include BaseInternshipOffer

    validates :remote_id,
              :permalink,
              presence: true

    validates :remote_id, uniqueness: { scope: :employer_id }

    after_initialize :init

    def init
      self.max_candidates ||= 1
      self.max_internship_week_number ||= 1
      self.is_public = false
    end
  end
end
