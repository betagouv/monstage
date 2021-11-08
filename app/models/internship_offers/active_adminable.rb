module InternshipOffers
  # wraps weekly logic
  module ActiveAdminable
    extend ActiveSupport::Concern

    included do
      def visible
        return "oui" if published?

        "non"
      end

      def supplied_applications
        InternshipApplication.where(internship_offer_id: id)
                             .where(aasm_state: ['approved', 'convention_signed'])
                             .count
      end

      rails_admin do
        configure :created_at, :datetime do
          date_format 'BUGGY'
        end

        show do
          exclude_fields :blocked_weeks_count,
                         :total_applications_count,
                         :convention_signed_applications_count,
                         :approved_applications_count,
                         :total_male_applications_count,
                         :total_male_convention_signed_applications_count,
                         :total_female_applications_count,
                         :total_female_convention_signed_applications_count,
                         :total_custom_track_convention_signed_applications_count,
                         :submitted_applications_count,
                         :rejected_applications_count,
                         :tutor
        end

        edit do
          field :title
          field :description
          field :max_candidates
          field :max_students_per_group
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
          field :description
          field :group
          field :school_track
          field :max_candidates
          field :max_students_per_group
          field :total_applications_count
          field :convention_signed_applications_count
          field :employer_name
          field :tutor_name
          field :tutor_phone
          field :tutor_email
          field :street
          field :zipcode
          field :departement
          field :city
          field :sector_name
          field :is_public
          field :supplied_applications
          field :visible
          field :created_at
          field :updated_at
        end
      end
    end
  end
end
