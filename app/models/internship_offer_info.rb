class InternshipOfferInfo < ApplicationRecord
  MAX_CANDIDATES_PER_GROUP = 200
  
  # Relation
  belongs_to :sector
  belongs_to :school, optional: true # reserved to school
  belongs_to :group, optional: true

  
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
end
