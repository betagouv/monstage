# frozen_string_literal: true

class InternshipOfferInfo < ApplicationRecord
  include Offerable

  # Relation
  belongs_to :internship_offer, optional: true
  belongs_to :employer, class_name: 'User'

  # Scopes
  scope :weekly_framed, lambda {
    where(type: [InternshipOfferInfos::WeeklyFramed.name,
                 InternshipOfferInfos::ApiInfo.name])
  }

  scope :free_date, lambda {
    where(type: InternshipOfferInfos::FreeDate.name)
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
end
