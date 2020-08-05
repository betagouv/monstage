# frozen_string_literal: true

module InternshipOfferInfos
  class WeeklyFramed < InternshipOfferInfo
    include WeeklyFramable

    rails_admin do
      configure :created_at, :datetime do
        date_format 'BUGGY'
      end

      list do
        scopes [:not_from_api]
        field :title
        field :zipcode
        field :employer_name
        field :group
        field :is_public
        field :department
        field :created_at
      end

      show do
        exclude_fields :blocked_weeks_count,
                       :total_applications_count,
                       :convention_signed_applications_count,
                       :approved_applications_count,
                       :total_male_applications_count,
                       :total_male_convention_signed_applications_count,
                       :total_custom_track_convention_signed_applications_count,
                       :submitted_applications_count,
                       :rejected_applications_count
      end

      edit do
        field :title
        field :description
        field :max_candidates
        field :tutor_name
        field :tutor_phone
        field :tutor_email
        field :employer_website
        field :discarded_at
        field :employer_name
        field :is_public
        field :group
        field :employer_description
        field :published_at
      end

      export do
        field :title
        field :employer_name
        field :group
        field :zipcode
        field :city
        field :max_candidates
        field :total_applications_count
        field :convention_signed_applications_count
      end
    end

    # validates :street,
    #           :city,
    #           :tutor_name,
    #           :tutor_phone,
    #           :tutor_email,
    #           presence: true

    # validates :is_public, inclusion: { in: [true, false] }
    #validate :validate_group_is_public?, if: false #lambda { |ioi| ioi.organisation.is_public? }
    #validate :validate_group_is_not_public?, unless: true #lambda { |ioi| ioi.organisation.is_public? }

    validates :max_candidates, numericality: { only_integer: true,
                                               greater_than: 0,
                                               less_than_or_equal_to: MAX_CANDIDATES_PER_GROUP }
    after_initialize :init
    # before_create :reverse_academy_by_zipcode

    attr_reader :with_operator

    def validate_group_is_public?
      return if group.nil?

      errors.add(:group, 'Veuillez choisir une institution de tutelle') unless group.is_public?
    end

    def validate_group_is_not_public?
      return if group.nil?

      errors.add(:group, 'Veuillez choisir une institution de tutelle') if group.is_public?
    end
  end
end
