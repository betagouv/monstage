module InternshipOffersHelper
  def format_autocomplete_address(internship_offer)
    [
      internship_offer.employer_street,
      internship_offer.employer_city,
      internship_offer.employer_zipcode
    ].compact.uniq.join(', ')
  end

  def intership_sectors_options_for_default
    "-- Veuillez sélectionner un secteur --"
  end

  def intership_sectors_options_for_select
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
      "Transport, Logistique",
      "Multi-secteur"
    ]
  end
end
