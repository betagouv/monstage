# frozen_string_literal: true

require 'test_helper'

class AcademyTest < ActiveSupport::TestCase
  test '.lookup_by_zipcode with departements in 97x' do
    assert_equal 'Académie de la Guadeloupe', Academy.lookup_by_zipcode(zipcode: '97100')
    assert_equal 'Académie de Martinique', Academy.lookup_by_zipcode(zipcode: '97200')
    assert_equal 'Académie de la Guyane', Academy.lookup_by_zipcode(zipcode: '97300')
    assert_equal 'Académie de La Réunion', Academy.lookup_by_zipcode(zipcode: '97400')
    assert_equal 'Académie de Caen', Academy.lookup_by_zipcode(zipcode: '97500')
    assert_equal 'Académie de la Guadeloupe', Academy.lookup_by_zipcode(zipcode: '97700')
    assert_equal 'Académie de la Guadeloupe', Academy.lookup_by_zipcode(zipcode: '97800')
  end

  test '.lookup_by_zipcode with other departements' do
    assert_equal 'Académie de Paris', Academy.lookup_by_zipcode(zipcode: '75015')
    assert_equal 'Académie de Versailles', Academy.lookup_by_zipcode(zipcode: '95270')
    assert_equal "Académie d'Amiens", Academy.lookup_by_zipcode(zipcode: '60580')
    assert_equal "Académie d'Aix-Marseille", Academy.lookup_by_zipcode(zipcode: '13001')
    assert_equal "Académie de Mayotte", Academy.lookup_by_zipcode(zipcode: '97600')
  end

  test '.to_select is sorted by alnum' do
    assert_equal 'Académie d\'Aix-Marseille', Academy.to_select.first
    assert_equal 'Académie de la Guyane', Academy.to_select.last
  end

  test '.get_email_domain' do
    assert_equal 'ac-aix-marseille.fr', Academy.get_email_domain('Académie d\'Aix-Marseille')
    assert_equal 'ac-guyane.fr', Academy.get_email_domain('Académie de la Guyane')
    assert_equal 'ac-normandie.fr', Academy.get_email_domain('Académie de Normandie')
  end
end
