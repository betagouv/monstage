module InternshipOffersScopes
  # find internship in a 60km radious from user.school
  module Applicable
    extend ActiveSupport::Concern

    included do
      scope :applicable, -> () {
      }
    end
  end
end
