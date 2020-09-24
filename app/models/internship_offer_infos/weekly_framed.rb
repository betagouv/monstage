# frozen_string_literal: true

module InternshipOfferInfos
  class WeeklyFramed < InternshipOfferInfo
    include WeeklyFramable
    include OfferWeeklyFramable
  end
end
