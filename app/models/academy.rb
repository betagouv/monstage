# see: https://fr.wikipedia.org/wiki/Acad%C3%A9mie_(%C3%A9ducation_en_France)#cite_note-RegAcad-16
class Academy
  MAP = {
    "Académie de Clermont-Ferrand" => %w[03 15 43 63],
    "Académie de Grenoble" => %w[07 26 38 73 74],
    "Académie de Lyon" => %w[01 42 69 69],
    "Académie de Besançon" => %w[25 39 70 90],
    "Académie de Dijon" => %w[21 58 71 89],
    "Académie de Rennes" => %w[22 29 35 56],
    "Académie d'OrléansTours" => %w[18 28 36 37 41 45],
    "Académie de Corse" => %w[2A 2B],
    "Académie de Nancy-Metz" => %w[54 55 57 88],
    "Académie de Reims" => %w[08 10 51 52],
    "Académie de Strasbourg" => %w[67 68],
    "Académie de la Guadeloupe" => %w[971 977 978],
    "Académie de la Guyane" => %w[973],
    "Académie d'Amiens" => %w[02 60 80],
    "Académie de Lille" => %w[59 62],
    "Académie de Créteil" => %w[77 93 94],
    "Académie de Paris" => %w[75],
    "Académie de Versailles" => %w[78 91 92 95],
    "Académie de Martinique" => %w[972],
    "Académie de Caen" => %w[14 50 61 975],
    "Académie de Rouen" => %w[27 76],
    "Académie de Bordeaux" => %w[24 33 40 47 64],
    "Académie de Limoges" => %w[19 23 87],
    "Académie de Poitiers" => %w[16 17 79 86],
    "Académie de Montpellier" => %w[11 30 34 48 66],
    "Académie de Toulouse" => %w[09 12 31 32 46 65 81 82],
    "Académie de Nantes" => %w[44 49 53 72 85],
    "Académie d'Aix-Marseille" => %w[04 05 13 84],
    "Académie de Nice" => %w[06 83],
    "Académie de La Réunion" => %w[974],
  }

  def self.names
    MAP.keys
  end

  def self.departements_by_name(academy_name:)
    MAP.fetch(academy_name)
  end

  def self.lookup_by_zipcode(zipcode:)
    MAP.map do |academy_name, departement_numbers|
      if departement_identified_by_3_chars?(zipcode: zipcode)
        return academy_name if departement_numbers.include?(zipcode[0..2])
      else
        return academy_name if departement_numbers.include?(zipcode[0..1])
      end
    end
  end

  # edge case for [971->978]
  def self.departement_identified_by_3_chars?(zipcode:)
    zipcode.starts_with?("97")
  end
end
