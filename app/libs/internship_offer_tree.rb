# This class purpose is the following :
# --------------------------
# some attributes are specific to the internship_offer table,
# all attrbutes of the internship_offer_info table , organisation table and
# tutor table are also attributes of the internship_offer table,
# these common attributes are to be updated in their root table,
# and then synchronized with the internship_offer table.
class InternshipOfferTree
  def check_or_create_underlying_objects
    return self if underlying_objects_exist?

    interpolated = organisation.nil?
    ActiveRecord::Base.transaction do
      create_underlying_tables
      internship_offer.reload
      internship_offer.update(db_interpolated: true) if interpolated
    end
  end

  def synchronize(instance)
    instance.synchronize(internship_offer)
    return internship_offer
  end

  attr_accessor :internship_offer, :internship_offer_info, :organisation, :tutor

  private


  def initialize(internship_offer:)
    @internship_offer = internship_offer
    @internship_offer_info = internship_offer&.internship_offer_info
    @organisation = @internship_offer&.organisation
    @tutor = @internship_offer&.tutor
  end

  def underlying_objects_exist?
    [internship_offer_info,
     organisation,
     tutor].none? { |object| object.nil? }
  end

  def create_underlying_tables
    ActiveRecord::Base.transaction do
      internship_offer.organisation_id = create_underlying_organisation
      internship_offer.internship_offer_info_id = create_underlying_internship_offer_info
      internship_offer.tutor_id = create_underlying_tutor
      internship_offer.save!
    end
  rescue
    puts "Error while creating underlying tables for internship_offer #{internship_offer.id}"
    Rails.logger.error "Error while creating underlying tables for internship_offer #{internship_offer.id}"
  end

  def create_underlying_organisation
    return internship_offer.organisation_id if internship_offer&.organisation_id

    organisation_attributes = { db_interpolated: true }
    organisation_attributes.merge!(
      Organisation.attributes_from_internship_offer(internship_offer_id: internship_offer.id)
    )
    organisation = Organisation.new(organisation_attributes)
    organisation.coordinates = internship_offer.coordinates
    organisation.employer_description_rich_text.body = internship_offer.employer_description_rich_text.body
    organisation.save!
    organisation.reload.id
  end

  def create_underlying_internship_offer_info
    return internship_offer.internship_offer_info_id if internship_offer.internship_offer_info_id

    internship_offer_info_attributes = InternshipOfferInfo.attributes_from_internship_offer(internship_offer_id: internship_offer.id)
    internship_offer_info = InternshipOfferInfo.new(internship_offer_info_attributes)
    internship_offer_info.coordinates = internship_offer.coordinates
    internship_offer_info.description_rich_text.body = internship_offer.description_rich_text.body
    internship_offer_info.save!
    internship_offer_info.reload.id
  end

  def create_underlying_tutor
    return internship_offer.tutor_id if internship_offer.tutor_id

    tutor_attributes = Tutor.attributes_from_internship_offer(internship_offer_id: internship_offer.id)
    tutor = Tutor.new(tutor_attributes)
    tutor.save!
    tutor.reload.id
  end
end
