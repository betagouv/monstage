module InternshipOffers
  class FreeDate < InternshipOffer
    has_many :internship_applications
    after_initialize :init

    #
    # callbacks
    #
    def sync_first_and_last_date
      school_year = SchoolYear::Floating.new(date: Date.today)
      self.first_date = school_year.beginning_of_period
      self.last_date = school_year.end_of_period
    end
  end
end
