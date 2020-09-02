module InternshipOffers
  # wraps weekly logic
  module ActiveAdminable
    extend ActiveSupport::Concern

    included do
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
          field :description
          field :group
          field :max_candidates
          field :total_applications_count
          field :convention_signed_applications_count
          field :group
          field :employer_name
          field :employer_email
          field :employer_phone
          field :tutor_name
          field :tutor_phone
          field :tutor_email
          field :street
          field :zipcode
          field :departement
          field :city
        end
      end
    end
  end
end
