# frozen_string_literal: true

module InternshipOffers
  class Api < InternshipOffer
    include WeeklyFramable

    rails_admin do
      configure :created_at, :datetime do
        date_format 'BUGGY'
      end

      list do
        scopes [:from_api]

        field :title
        field :zipcode
        field :employer_name
        field :is_public
        field :department
        field :created_at
      end

      edit do
        field :title
        field :description
        field :employer_name
        field :employer_description
        field :employer_website
        field :street
        field :zipcode
        field :city
        field :sector
        field :weeks
        field :remote_id
        field :permalink
        field :max_candidates
        field :is_public
      end

      export do
        field :title
        field :employer_name
        field :zipcode
        field :city
        field :max_candidates
        field :total_applications_count
        field :approved_applications_count
        field :rejected_applications_count
        field :convention_signed_applications_count
        field :is_public
      end

      show do
      end
    end

    validates :remote_id,
              :permalink,
              presence: true

    validates :zipcode, zipcode: { country_code: :fr }
    validates :remote_id, uniqueness: { scope: :employer_id }

    belongs_to :group, optional: true
    after_initialize :init


    def init
      self.max_candidates ||= 1
      self.is_public ||= false
    end

    def formatted_coordinates
      {
        latitude: coordinates.latitude,
        longitude: coordinates.longitude
      }
    end

    def as_json(options = {})
      super(options.merge(
        only: %i[title
                 description
                 employer_name
                 employer_description
                 employer_website
                 street
                 zipcode
                 city
                 remote_id
                 permalink
                 sector_uuid
                 max_candidates
                 published_at],
        methods: [:formatted_coordinates]
      ))
    end
  end
end
