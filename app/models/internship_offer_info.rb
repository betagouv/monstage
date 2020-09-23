# frozen_string_literal: true

class InternshipOfferInfo < ApplicationRecord
  include Offerable

  # Relation
  belongs_to :internship_offer, optional: true

  # Scopes 
  scope :weekly_framed, lambda {
    where(type: [InternshipOfferInfos::WeeklyFramedInfo.name,
                 InternshipOfferInfos::ApiInfo.name])
  }

  scope :free_date, lambda {
    where(type: InternshipOfferInfos::FreeDateInfo.name)
  }

  def replicate_rich_text_to_raw_fields
    self.description = description_rich_text.to_plain_text if description_rich_text.to_s.present?
  end
  
  def weekly?
    false
  end

  def free_date?
    false
  end

  def class_prefix_for_multiple_checkboxes
    'internship_offer_info'
  end

  def self.build_from_internship_offer(internship_offer)
    info = InternshipOfferInfo.new(
      title: internship_offer.employer_name,
      description: internship_offer.description,
      max_candidates: internship_offer.max_candidates,
      school_id: internship_offer.school_id,
      employer_id: internship_offer.employer_id,
      type: "InternshipOfferInfos::#{internship_offer.type.split('::').last}Info",
      sector_id: internship_offer.sector_id,
      daily_hours: internship_offer.daily_hours,
    )
    info.weeks << internship_offer.weeks
    info
  end
end
