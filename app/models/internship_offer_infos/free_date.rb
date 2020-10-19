module InternshipOfferInfos
  class FreeDate < InternshipOfferInfo
    attr_accessor :week_ids

    def weekly?
      false
    end

    def free_date?
      true
    end
  end
end
