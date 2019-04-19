require 'test_helper'
module Reporting
  class InternshipOfferTest < ActiveSupport::TestCase
    test 'views can be queried' do
      create(:internship_offer)
      create(:internship_offer)
      create(:internship_offer)
      assert_equal 3, Reporting::InternshipOffer.count
    end

    test 'views items support required attributes for reporting' do
      create(:internship_offer)
      internship_offer_reportable = Reporting::InternshipOffer.first
      attribute_names = internship_offer_reportable.attribute_names
      assert_includes attribute_names, "title"
      assert_includes attribute_names, "zipcode"
      assert_includes attribute_names, "departement_name"
      assert_includes attribute_names, "departement_code"
      assert_includes attribute_names, "region"
      assert_includes attribute_names, "academy"
      assert_includes attribute_names, "publicly_name"
      assert_includes attribute_names, "publicly_code"
      assert_includes attribute_names, "sector_name"
      assert_includes attribute_names, "blocked_weeks_count"
      assert_includes attribute_names, "total_applications_count"
      assert_includes attribute_names, "convention_signed_applications_count"
      assert_includes attribute_names, "approved_applications_count"
    end

    # Liste des collèges inscrits et des collèges non-inscrits
    # Nombre d’offres disponibles
    #   Selon le secteur privé ou public
    #   Selon le secteur d’activité
    # Liste des offres disponibles
    #   Selon le secteur privé ou public
    #   Selon le secteur d’activité
    # Nombre des candidatures
    #   Selon le secteur privé ou public
    #   Selon le secteur d’activité
    #   Selon les genres
    #   # -- Selon le caractère REP ou REP+ des collèges
    # Liste des candidatures  selon les mêmes discriminants (export excel)
    #   Nombre de stages effectués
    #   Selon le secteur privé ou public
    #   Selon le secteur d’activité
    #   Selon les genres
    #   Selon le caractère REP ou REP+ des collèges
    #   Liste des stages réalisés  selon les mêmes discriminants (export excel)
    #   Nombre de stages pris en charge par les opérateurs
    #   Liste des stages   accompagnés par un opérateur  (export excel)
  end
end

