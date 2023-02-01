# wrap shared behaviour between internship offer / organisation [by stepper]
module StepperProxy
  module Organisation
    extend ActiveSupport::Concern

    included do
      include Nearbyable

      # after_update :update_internship_offer

      belongs_to :group, optional: true

      validates :employer_name,
                :street,
                :zipcode,
                :city,
                presence: true,
                unless: :db_interpolated?

      validates :employer_description, length: { maximum: InternshipOffer::EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT }

      validates :is_public,
                inclusion: { in: [true, false] },
                unless: :db_interpolated?

      validates :siret,
                length: { is: 14 },
                allow_blank: true,
                unless: :db_interpolated?

      validate :validate_group_is_public?,
               if: :is_public?

      validate :validate_group_is_not_public?,
               unless: :is_public?

      has_rich_text :employer_description_rich_text

      before_validation :replicate_employer_description_rich_text_to_raw_field, unless: :from_api?
      before_validation :clean_siret

      def replicate_employer_description_rich_text_to_raw_field
        self.employer_description = employer_description_rich_text.to_plain_text if employer_description_rich_text.present?
      end

      def validate_group_is_public?
        return if from_api?
        return if group.nil?

        errors.add(:group, 'Veuillez choisir une institution de tutelle') unless group.is_public?
      end

      def validate_group_is_not_public?
        return if from_api?
        return if group.nil?

        errors.add(:group, 'Veuillez choisir une institution de tutelle') if group.is_public?
      end

      def clean_siret
        self.siret = self.siret.gsub(' ', '') if self.try(:siret)
      end

      def self.attributes_from_internship_offer(internship_offer_id:)
        internship_offer = InternshipOffer.find_by(id: internship_offer_id)
        {
          employer_name: internship_offer.employer_name,
          employer_website: internship_offer.employer_website,
          employer_description: internship_offer.employer_description,
          is_public: internship_offer.is_public,
          group_id: internship_offer.group_id,
          siret: internship_offer.siret,
          city: internship_offer.city,
          zipcode: internship_offer.zipcode,
          street: internship_offer.street,
          employer_id: internship_offer.employer_id
        }
      end

      def synchronize(internship_offer)
        extra_parameters = {
          street: street,
          zipcode: zipcode,
          city: city,
          organisation_id: id,
          coordinates: coordinates,
          db_interpolated: db_interpolated
        }
        parameters = InternshipOffers::WeeklyFramed.preprocess_organisation_to_params(self)
                                                  .merge(extra_parameters)
        internship_offer.update(parameters)
        internship_offer
      end

      # def update_internship_offer
      #   puts '================'
      #   puts "self.class.name : #{self.class.name}"
      #   puts "self.organisation_id : #{self.attributes}"
      #   puts '================'
      #   puts ''
      #   id = (self.class.name == 'Organisation') ? self.id : self.organisation_id
      #   organisation = ::Organisation.find_by(id: id)
      #   internship_offer = InternshipOffers::WeeklyFramed.find_by(organisation_id: id)
      #   if internship_offer.present?
      #     internship_offer.organisation_id = organisation.id
      #     internship_offer.employer_name = organisation.employer_name
      #     internship_offer.employer_website = organisation.employer_website
      #     internship_offer.employer_description = organisation.employer_description
      #     internship_offer.employer_description_rich_text = organisation.employer_description
      #     internship_offer.is_public = organisation.is_public
      #     internship_offer.group_id = organisation.group_id
      #     internship_offer.siret = organisation.siret
      #     internship_offer.employer_manual_enter = organisation.manual_enter

      #     internship_offer.save!
      #   end
      # end
    end
  end
end
