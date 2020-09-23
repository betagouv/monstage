# frozen_string_literal: true

module InternshipOfferInfos
  class WeeklyFramedInfo < InternshipOfferInfo
    include WeeklyFramable
    include OfferWeeklyFramable
  end
end
