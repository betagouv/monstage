# frozen_string_literal: true

module InternshipOffers
  class Api < InternshipOffer
    include WeeklyFramable
    include Apisable
  end
end
