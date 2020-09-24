# frozen_string_literal: true

module Offerable
  extend ActiveSupport::Concern

  included do
    MAX_CANDIDATES_PER_GROUP = 200
    TITLE_MAX_CHAR_COUNT = 150
    DESCRIPTION_MAX_CHAR_COUNT= 500
    
    # Relations
    belongs_to :sector
    belongs_to :school, optional: true # reserved to school
    belongs_to :group, optional: true
    
    # Validations
    validates :title, presence: true, length: { maximum: TITLE_MAX_CHAR_COUNT }
    validates :school_track, presence: true

    has_rich_text :description_rich_text

    before_validation :replicate_rich_text_to_raw_fields

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
    
    def init
      self.max_candidates ||= 1
    end
  end
end
