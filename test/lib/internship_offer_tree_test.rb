require 'test_helper'

class InternshipOfferTreeTest < ActiveSupport::TestCase
  test '#create_underlying_tables when no need' do
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    internship_offer_info = create(:weekly_internship_offer_info)
    tutor = create(:tutor, employer: employer)
    internship_offer = create(:weekly_internship_offer,
                              organisation: organisation,
                              employer: employer,
                              tutor: tutor,
                              internship_offer_info: internship_offer_info)
    [Organisation, Tutor, InternshipOfferInfo, InternshipOffer].each do |model|
      assert_equal 1, model.all.count
    end
    assert_equal organisation, internship_offer.organisation
    assert_equal employer, internship_offer.employer
    assert_equal tutor, internship_offer.tutor
    assert_equal internship_offer_info, internship_offer.internship_offer_info

    tree = InternshipOfferTree.new(internship_offer: internship_offer)
    tree.check_or_create_underlying_objects

    internship_offer = internship_offer.reload
    [Organisation, Tutor, InternshipOfferInfo, InternshipOffer].each do |model|
      assert_equal 1, model.all.count
    end
    assert_equal organisation, internship_offer.organisation
    assert_equal employer, internship_offer.employer
    assert_equal tutor, internship_offer.tutor
    assert_equal internship_offer_info, internship_offer.internship_offer_info
  end

  test '#create_underlying_tables when missing organisation' do
    internship_offer_info = create(:weekly_internship_offer_info)
    employer = internship_offer_info.employer
    tutor = create(:tutor)
    internship_offer = create(:weekly_internship_offer,
                              employer: employer,
                              tutor: tutor,
                              internship_offer_info_id: internship_offer_info.id)
    assert_equal 0, Organisation.all.count

    tree = InternshipOfferTree.new(internship_offer: internship_offer)
    tree.check_or_create_underlying_objects

    [Organisation, Tutor, InternshipOfferInfo, InternshipOffer].each do |model|
      assert_equal 1, model.all.count
    end

    organisation = internship_offer.organisation
    refute_nil organisation
    assert_equal employer.id, organisation.employer.id
    assert_equal internship_offer.street, organisation.street
    assert_equal internship_offer.city, organisation.city
    assert_equal internship_offer.zipcode, organisation.zipcode
    assert_equal internship_offer.employer_name, organisation.employer_name
    assert_equal internship_offer.employer_website, organisation.employer_website
    assert_equal internship_offer.employer_description, organisation.employer_description
    assert_equal internship_offer.employer_description_rich_text.body, organisation.employer_description_rich_text.body

  end

  test '#create_underlying_tables when missing internship_offer_info' do
    organisation = create(:organisation)
    employer = organisation.employer
    tutor = create(:tutor, employer_id: employer.id)
    internship_offer = create(:weekly_internship_offer,
                              organisation: organisation,
                              employer: employer,
                              tutor: tutor)
    assert_equal 1, Organisation.all.count
    assert_equal 0, InternshipOfferInfo.all.count
    refute_nil internship_offer.organisation

    tree = InternshipOfferTree.new(internship_offer: internship_offer)
    tree.check_or_create_underlying_objects

    assert_equal 1, Organisation.all.count
    assert_equal 1, Tutor.all.count
    assert_equal 1, InternshipOfferInfo.all.count
    assert_equal 1, InternshipOffer.all.count

    internship_offer_info = internship_offer.internship_offer_info
    refute_nil internship_offer_info
    assert_equal employer.id, internship_offer_info.employer.id
    assert_equal internship_offer.street, internship_offer_info.street
    assert_equal internship_offer.city, internship_offer_info.city
    assert_equal internship_offer.zipcode, internship_offer_info.zipcode
    assert_equal internship_offer.coordinates, internship_offer_info.coordinates
    assert_equal internship_offer.description, internship_offer_info.description
    assert_equal internship_offer.description_rich_text.body, internship_offer_info.description_rich_text.body
    assert_equal internship_offer.title, internship_offer_info.title
    assert_equal internship_offer.weekly_hours, internship_offer_info.weekly_hours
    assert_equal internship_offer.max_candidates, internship_offer_info.max_candidates
    assert_equal internship_offer.employer_name, internship_offer_info.employer_name
    assert_equal internship_offer.sector.id, internship_offer_info.sector.id
    assert_equal internship_offer.daily_lunch_break, internship_offer_info.daily_lunch_break
    assert_equal internship_offer.weekly_lunch_break, internship_offer_info.weekly_lunch_break
    assert_equal internship_offer.week_ids, internship_offer_info.week_ids
  end

  test '#create_underlying_tables when missing tutor' do
    organisation = create(:organisation)
    employer = organisation.employer
    internship_offer_info = create(:weekly_internship_offer_info, employer: employer)
    internship_offer = create(:weekly_internship_offer,
                              organisation: organisation,
                              employer: employer,
                              internship_offer_info: internship_offer_info)
    assert_equal 0, Tutor.all.count

    tree = InternshipOfferTree.new(internship_offer: internship_offer)
    tree.check_or_create_underlying_objects

    [Organisation, Tutor, InternshipOfferInfo, InternshipOffer].each do |model|
      assert_equal 1, model.all.count
    end

    tutor = Tutor.take

    refute_nil tutor
    assert_equal internship_offer.tutor_id, tutor.id
    assert_equal internship_offer.tutor_name, tutor.tutor_name
    assert_equal internship_offer.tutor_email, tutor.tutor_email
    assert_equal internship_offer.tutor_phone, tutor.tutor_phone
    assert_equal internship_offer.tutor_role, tutor.tutor_role
    assert_equal internship_offer.employer_id, tutor.employer_id
  end
end
