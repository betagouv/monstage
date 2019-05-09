module InternshipOffersHelper
  def current_sector_name
    return Sector.find(params[:sector_id]).name if params[:sector_id]
    'Tous'
  end

  def current_sector_url
    return Sector.find(params[:sector_id]).external_url if params[:sector_id]
    'http://www.onisep.fr/Decouvrir-les-metiers/Des-metiers-par-secteur'
  end

  def options_for_group_names
    administration_list.map { |admin| [admin, { 'data-sector' => 'public'}] } +
        group_list.map { |admin| [admin, { 'data-sector' => 'private'}] }
  end

  def administration_list
    [
        "ELYSEE",
        "MATIGNON",
        "MINISTERE DE L'ACTION ET DES COMPTES PUBLICS",
        "MINISTERE DE L'ECONOMIE ET DES FINANCES",
        "MINISTERE DE LA TRANSITION ECOLOGIQUE ET SOLIDAIRE",
        "MINISTERE DES ARMEES",
        "MINISTERE DE L'AGRICULTURE ET DE L'ALIMENTATION",
        "MINISTERE DES SOLIDARITES ET DE LA SANTE",
        "MINISTERE DE L'INTERIEUR",
        "MINITERE DE LA JUSTICE",
        "MINITERE DE LA CULTURE",
        "MINISTERE DE L'EUROPE ET DES AFFAIRES ETRANGERES",
        "MINISTERE DE LA COHESION DES TERRITOIRES",
        "MINISTERE DE L'EDUCATION NATIONALE ET DE LA JEUNESSE",
        "MINISTERE DES OUTRE-MER"
    ]
  end

  def group_list
    [
        "Accenture",
        "AccorHotels",
        "Adecco Group",
        "Afep",
        "Air France",
        "Amundi",
        "AUXI'LIFE",
        "AXA",
        "BIC",
        "BNP Paribas",
        "Bosch",
        "BPCE",
        "Bpifrance",
        "CA Brie Picardie",
        "CA Centre Est",
        "Carrefour",
        "CNP",
        "Coca-Cola European Partners France",
        "Coca-Cola France",
        "COMERSO",
        "Crédit Mutuel - CIC",
        "E. Leclerc",
        "Elior",
        "Engie",
        "EPSA",
        "FDJ",
        "FFB",
        "Fives",
        "FRTP",
        "Generali",
        "Genfit",
        "Groupe Sémaphores",
        "Groupe SKF",
        "Groupe Vicat",
        "GTT",
        "Guerbet",
        "Henkel",
        "Icade",
        "ICF Habitat",
        "Inditex",
        "Klépierre",
        "Korian",
        "Korn Ferry",
        "La Poste",
        "L'Oréal",
        "Louvre Hotels Group",
        "ManpowerGroup",
        "Michelin",
        "O2",
        "Ostrum Asset Management",
        "PROACTIVE ACADEMY",
        "Procter & Gamble",
        "Recyc-Matelas Europe",
        "Safran",
        "Saguez & Partners",
        "Sanofi",
        "Schneider Electric",
        "Shell",
        "Siemens",
        "SNCF",
        "Sodexo",
        "Starbucks",
        "Suez",
        "SWEN Capital Partners",
        "Système U",
        "Unibail-Rodamco-Westfield",
        "Valeo",
        "Vivendi"
    ]
  end
end
