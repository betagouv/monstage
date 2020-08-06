# frozen_string_literal: true

class InternshipOfferInfo < ApplicationRecord
  MAX_CANDIDATES_PER_GROUP = 200
  TITLE_MAX_CHAR_COUNT = 150
    
  # Relation
  belongs_to :sector
  belongs_to :school, optional: true # reserved to school
  belongs_to :group, optional: true

  has_rich_text :description_rich_text

  before_validation :replicate_rich_text_to_raw_fields
  
  # Validations
  validates :title, presence: true,
                    length: { maximum: TITLE_MAX_CHAR_COUNT }

  # Scopes 
  scope :weekly_framed, lambda {
    where(type: [InternshipOfferInfos::WeeklyFramed.name,
                 InternshipOfferInfos::Api.name])
  }

  scope :free_date, lambda {
    where(type: InternshipOfferInfos::FreeDate.name)
  }


  def replicate_rich_text_to_raw_fields
    self.description = description_rich_text.to_plain_text if description_rich_text.to_s.present?
  end
  
  def is_individual?
    max_candidates == 1
  end

  def from_api?
    permalink.present?
  end

  def reserved_to_school?
    school.present?
  end

  def is_fully_editable?
    true
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

  def init
    self.max_candidates ||= 1
  end
end
