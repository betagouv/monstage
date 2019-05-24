# frozen_string_literal: true

module InternshipOffersScopes
  # find internship with school_id or ignores those with a school id different
  module BySchool
    extend ActiveSupport::Concern

    included do
      scope :ignore_internship_restricted_to_other_schools, lambda { |school_id:|
        InternshipOffer.where(school_id: [nil, school_id])
      }
    end
  end
end
