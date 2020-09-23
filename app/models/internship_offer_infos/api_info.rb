# frozen_string_literal: true

module InternshipOfferInfos
  class ApiInfo < InternshipOfferInfo
    include WeeklyFramable
    include Apisable
  end
end
