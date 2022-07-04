# === TODO
# This file should be deleted when staging remaining internship offers are anonymized
# since in 2022-2023, there won't be any more free internship offers.
# === TODO
module InternshipOffers
  class FreeDate < InternshipOffer
    attr_accessor :week_ids

    rails_admin do
      weight 12
      navigation_label "Offres"

      list do
        scopes [:kept, :discarded]
        field :title
        field :department
        field :zipcode
        field :employer_name
        field :group
        field :is_public
        field :created_at
      end

      edit do
        field :title
        field :description
        field :sector
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
        field :school
      end
    end

    # scope to request internship offers
    scope :ignore_already_applied, lambda { |user:|
      where.not(
        id: joins(:internship_applications).merge(InternshipApplication.where(user_id: user.id))
      )
    }

    def weekly?
      false
    end

    def free_date?
      true
    end

    def has_spots_left?
      true
    end

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
