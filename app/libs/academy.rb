# frozen_string_literal: true

# see: https://fr.wikipedia.org/wiki/Acad%C3%A9mie_(%C3%A9ducation_en_France)#cite_note-RegAcad-16
class Academy
  MAP = {
    'Académie de Clermont-Ferrand' => %w[03 15 43 63],
    'Académie de Grenoble' => %w[07 26 38 73 74],
    'Académie de Lyon' => %w[01 42 69 69],
    'Académie de Besançon' => %w[25 39 70 90],
    'Académie de Dijon' => %w[21 58 71 89],
    'Académie de Rennes' => %w[22 29 35 56],
    "Académie d'OrléansTours" => %w[18 28 36 37 41 45],
    'Académie de Corse' => %w[2A 2B],
    'Académie de Nancy-Metz' => %w[54 55 57 88],
    'Académie de Reims' => %w[08 10 51 52],
    'Académie de Strasbourg' => %w[67 68],
    'Académie de la Guadeloupe' => %w[971 977 978],
    'Académie de la Guyane' => %w[973],
    "Académie d'Amiens" => %w[02 60 80],
    'Académie de Lille' => %w[59 62],
    'Académie de Créteil' => %w[77 93 94],
    'Académie de Paris' => %w[75],
    'Académie de Versailles' => %w[78 91 92 95],
    'Académie de Martinique' => %w[972],
    'Académie de Caen' => %w[14 50 61 975],
    'Académie de Normandie' => %w[14 50 61 975 27 76],
    'Académie de Rouen' => %w[27 76],
    'Académie de Bordeaux' => %w[24 33 40 47 64],
    'Académie de Limoges' => %w[19 23 87],
    'Académie de Poitiers' => %w[16 17 79 86],
    'Académie de Montpellier' => %w[11 30 34 48 66],
    'Académie de Toulouse' => %w[09 12 31 32 46 65 81 82],
    'Académie de Nantes' => %w[44 49 53 72 85],
    "Académie d'Aix-Marseille" => %w[04 05 13 84],
    'Académie de Nice' => %w[06 83],
    'Académie de La Réunion' => %w[974],
    'Académie de Mayotte' => %w[976],
  }.freeze

  MAP_EMAIL_DOMAIN = {
    'Académie de Clermont-Ferrand' => 'ac-clermont.fr',
    'Académie de Grenoble' => 'ac-grenoble.fr',
    'Académie de Lyon' => 'ac-lyon.fr',
    'Académie de Besançon' => 'ac-besancon.fr',
    'Académie de Dijon' => 'ac-dijon.fr',
    'Académie de Rennes' => 'ac-rennes.fr',
    "Académie d'OrléansTours" => 'ac-orleans-tours.fr',
    'Académie de Corse' => 'ac-corse.fr',
    'Académie de Nancy-Metz' => 'ac-nancy-metz.fr',
    'Académie de Reims' => 'ac-reims.fr',
    'Académie de Strasbourg' => 'ac-strasbourg.fr',
    'Académie de la Guadeloupe' => 'ac-guadeloupe.fr',
    'Académie de la Guyane' => 'ac-guyane.fr',
    "Académie d'Amiens" => 'ac-amiens.fr',
    'Académie de Lille' => 'ac-lille.fr',
    'Académie de Créteil' => 'ac-creteil.fr',
    'Académie de Paris' => 'ac-paris.fr',
    'Académie de Versailles' => 'ac-versailles.fr',
    'Académie de Martinique' => 'ac-martinique.fr',
    'Académie de Caen' => 'ac-caen.fr',
    'Académie de Rouen' => 'ac-rouen.fr',
    'Académie de Normandie' => 'ac-normandie.fr',
    'Académie de Bordeaux' => 'ac-bordeaux.fr',
    'Académie de Limoges' => 'ac-limoges.fr',
    'Académie de Poitiers' => 'ac-poitiers.fr',
    'Académie de Montpellier' => 'ac-montpellier.fr',
    'Académie de Toulouse' => 'ac-toulouse.fr',
    'Académie de Nantes' => 'ac-nantes.fr',
    "Académie d'Aix-Marseille" => 'ac-aix-marseille.fr',
    'Académie de Nice' => 'ac-nice.fr',
    'Académie de La Réunion' => 'ac-reunion.fr',
    'Académie de Mayotte' => 'ac-mayotte.fr'
  }.freeze

  def self.to_select(only: nil)
    MAP.keys.sort
  end

  def self.departments_by_name(academy:)
    MAP.fetch(academy)
  end

  def self.lookup_by_zipcode(zipcode:)
    MAP.map do |academy_name, departement_numbers|
      if ::Department.departement_identified_by_3_chars?(zipcode: zipcode)
        return academy_name if departement_numbers.include?(zipcode[0..2])
      elsif zipcode[0..1] == '20'
        return 'Académie de Corse' 
      elsif departement_numbers.include?(zipcode[0..1])
        return academy_name
      end
    end
  end

  def self.get_email_domain(academy)
    MAP_EMAIL_DOMAIN.fetch(academy)
  end
end
