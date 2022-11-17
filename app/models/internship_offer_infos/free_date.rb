module InternshipOfferInfos
  class FreeDate < InternshipOfferInfo
    attr_accessor :week_ids

    def free_date?
      true
    end
  end
end
