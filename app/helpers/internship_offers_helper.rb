module InternshipOffersHelper
  def internship_sectors_options_for_default
    "-- Veuillez sélectionner un domaine --"
  end

  def internship_sectors_options_for_select
    [
      'Aérien, Aéronautique et Aéroportuaire',
      "Agriculture, Elevage, Pêche",
      "Agroalimentaire, Industrie agroalimentaire",
      "Animaux",
      "Artisanat, Commerce de détail",
      "Audiovisuel, Cinéma",
      "Audit, Comptabilité, Gestion",
      "Automobile",
      "Banque, Assurance, Finance",
      "Bâtiment, Travaux publics, Architecture",
      "Biologie, Chimie, Pharmacie",
      "Commerce, Vente, Distribution",
      "Communication, Médias",
      "Culture, Patrimoine",
      "Défense, Sécurité",
      "Design, Graphisme, Multimédia",
      "Direction générale, Stratégie, Conseil, Organisation",
      "Droit, Justice",
      "Edition, Bibliothèque, Livre",
      "Enseignement, Formation",
      "Environnement, Eau, Nature, Propreté",
      "Fonction publique",
      "Hôtellerie - Restauration",
      "Humanitaire",
      "Immobilier",
      "Industrie, Maintenance, Energie",
      "Informatique, Digital, Télécom",
      "Ingénierie",
      "Journalisme",
      "Langue",
      "Marketing",
      "Medical",
      "Mode, Luxe, Industrie textile",
      "Paramédical",
      "Psychologie",
      "Ressources Humaines",
      "Sciences Humaines et Sociales",
      "Sciences, Maths, Physique, Recherche",
      "Secrétariat, Accueil",
      "Services à la personne, Entretien",
      "Social, Vie associative",
      "Soins esthétiques, Coiffure",
      "Spectacle, Métiers de la scène",
      "Sport, Animation",
      "Tourisme, Loisirs",
      "Transport, Logistique"
    ]
  end

  def operator_names
    [
        "Clubs régionaux  d'entreprises pour l'insertion (CREPI)",
        "Dégun sans stage (Ecole centrale de Marseille)",
        "Fondation Agir contre l'Exclusion (FACE)",
        "JOB IRL",
        "Les entreprises pour la cité (LEPC)",
        "Un stage et après !",
        "Tous en stage",
        "Viens voir mon taf"
    ]
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
