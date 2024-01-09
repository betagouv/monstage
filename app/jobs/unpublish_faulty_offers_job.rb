class UnpublishFaultyOffersJob < ApplicationJob
  queue_as :default

  def perform
    InternshipOffers::WeeklyFramed.update_older_internship_offers
  end
end
