# wrap shared behaviour between internship offer / organisation [by stepper]
module StepperProxy
  module Organisation
    extend ActiveSupport::Concern

    included do
      include Nearbyable

      belongs_to :group, optional: true

      validates :employer_name,
                :street,
                :zipcode,
                :city, presence: true

      validates :employer_description, length: { maximum: InternshipOffer::EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT }

      validates :is_public, inclusion: { in: [true, false] }
      validates :siret, length: { is: 14 }, allow_blank: true

      validate :validate_group_is_public?, if: :is_public?
      validate :validate_group_is_not_public?, unless: :is_public?

      has_rich_text :employer_description_rich_text

      before_validation :replicate_employer_description_rich_text_to_raw_field, unless: :from_api?
      before_validation :clean_siret

      def replicate_employer_description_rich_text_to_raw_field
        return unless employer_description_rich_text.present?

        self.employer_description = employer_description_copy_cleaning(employer_description_rich_text.to_plain_text || '')
      end

      def employer_description_copy_cleaning(str)
        raise 'error in employer_description_copy_cleaning' if str.nil?

        str.gsub(/[\n\r\t]/, '')
           .strip
           .truncate(InternshipOffer::EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT)
      end

      def description_copy_cleaning(str)
        raise 'error in description_copy_cleaning' if str.nil?

        str.gsub(/[\n\r\t]/, '')
           .strip
           .truncate(InternshipOffer::DESCRIPTION_MAX_CHAR_COUNT)
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
        self.siret = siret.gsub(' ', '') if try(:siret)
      end
    end
  end
end
