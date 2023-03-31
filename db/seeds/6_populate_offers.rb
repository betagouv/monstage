def populate_internship_offers
  # 3eme_generale: public sector
  weeks = Week.selectable_on_school_year
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    siret: siret,
    max_candidates: 5,
    max_students_per_group: 5,
    weeks: weeks,
    first_date: weeks.first.beginning_of_week,
    last_date: weeks.last.beginning_of_week,
    sector: Sector.first,
    group: Group.is_paqte.first,
    is_public: false,
    title: 'Stage assistant.e ressources humaines - Service des recrutements',
    description_rich_text: 'Vous assistez la responsable de secteur dans la gestion du recrutement des intervenant.e.s à domicile et la gestion des contrats de celles et ceux en contrat avec des particulier-employeurs.',
    employer_description_rich_text: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile.",
    employer_website: 'http://www.dtpm.fr/',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_role: 'Chef comptable',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: Group.is_paqte.first.name
  )
  weeks = [].concat(Week.selectable_on_school_year[0..1], Week.selectable_on_school_year[3..5])
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    siret: siret,
    max_candidates: 5,
    max_students_per_group: 5,
    weeks: weeks,
    first_date: weeks.first.beginning_of_week,
    last_date: weeks.last.beginning_of_week,
    sector: Sector.first,
    group: Group.is_paqte.first,
    is_public: false,
    title: 'Stage avec deux segments de date, bugfix',
    description_rich_text: 'Scanner metrology est une entreprise unique en son genre'.truncate(249),
    employer_description_rich_text: "Scanner metrology a été fondée par le laureat Recherche et Company 2016".truncate(249),
    employer_website: 'https://www.asml.com/en/careers',
    tutor_name: 'John smith',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    tutor_role: 'Chef comptable',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: Group.is_paqte.first.name
  )

    # 3eme generale public
  weeks =  Week.selectable_on_school_year
  InternshipOffers::WeeklyFramed.create!(
    max_candidates: 5,
    max_students_per_group: 5,
    employer: Users::Employer.first,
    siret: siret,
    weeks: weeks,
    first_date: weeks.first.beginning_of_week,
    last_date: weeks.last.beginning_of_week,
    sector: Sector.second,
    group: Group.is_public.last,
    is_public: true,
    title: "Observation du métier de chef de service - Ministère",
    description: "Découvrez les réunions et comment se prennent les décisions au plus haut niveau mais aussi tous les interlocuteurs de notre société qui intéragissent avec nos services ",
    description_rich_text: "Venez découvrir le métier de chef de service ! Vous observerez comment nos administrateurs garantissent aux usagers l'exercice de leur droits, tout en respectant leurs devoirs.",
    employer_description_rich_text: "De multiples méthodes de travail et de prises de décisions seront observées",
    tutor_name: 'Etienne Weil',
    tutor_email: 'etienne@free.fr',
    tutor_role: 'Chef comptable',
    tutor_phone: '+33637697756',
    street: '18 rue Damiens',
    zipcode: '75012',
    city: 'paris',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: Group.is_public.last.name
  )
  InternshipOffers::WeeklyFramed.create!(
    max_candidates: 5,
    max_students_per_group: 5,
    employer: Users::Employer.first,
    siret: siret,
    weeks: weeks,
    first_date: weeks.first.beginning_of_week,
    last_date: weeks.last.beginning_of_week,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Stage assistant.e banque et assurance',
    description_rich_text: 'Vous assistez la responsable de secteur dans la gestion du recrutement des intervenant.e.s à domicile et la gestion des contrats de celles et ceux en contrat avec des particulier-employeurs.',
    employer_description_rich_text: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile pour la garde de leurs enfants de 0 à 16 ans.",
    employer_website: 'http://www.dtpm.fr/',
    tutor_name: 'Gilles Charles',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    tutor_role: 'Chef comptable',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'Du temps pour moi'
  )
  # dépubliée
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    siret: siret,
    weeks: weeks,
    first_date: weeks.first.beginning_of_week,
    last_date: weeks.last.beginning_of_week,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: '(non publiée) Stage assistant.e banque et assurance',
    description_rich_text: 'Vous assistez la responsable de secteur dans la gestion du recrutement des intervenant.e.s à domicile et la gestion des contrats de celles et ceux en contrat avec des particulier-employeurs.',
    employer_description_rich_text: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile pour la garde de leurs enfants de 0 à 16 ans.",
    employer_website: 'http://www.dtpm.fr/',
    tutor_name: 'Gilles Charles',
    tutor_email: 'fourcadex.m@gmail.com',
    tutor_phone: '+33637607756',
    tutor_role: 'Chef comptable',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'Du temps pour moi',
    max_candidates: 7,
    max_students_per_group: 7
  )
  io = InternshipOffer.last
  io.published_at = nil
  io.save

  # 3eme_generale-2019:
  weeks =  Week.weeks_of_school_year(school_year: SchoolYear::Base::YEAR_START)
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    siret: siret,
    weeks: weeks,
    first_date: weeks.first.beginning_of_week,
    last_date: weeks.last.beginning_of_week,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Stage editeur - A la recherche du temps passé par les collaborateurs',
    description_rich_text: 'Vous assistez la responsable de secteur dans la gestion des projets internes touchant à la gestion des contrats.',
    employer_description_rich_text: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile pour la garde de leurs enfants de 0 à 16 ans.",
    employer_website: 'http://www.dtpm.fr/',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_role: 'Chef magasinier',
    tutor_phone: '+33637677756',
    street: '129 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: 'Editegis'
  )
  # 3eme generale API
  weeks =  Week.selectable_on_school_year
  InternshipOffers::Api.create!(
    employer: Users::Operator.first,
    siret: siret,
    weeks: weeks,
    first_date: weeks.first.beginning_of_week,
    last_date: weeks.last.beginning_of_week,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: "Observation du métier d'Administrateur de systèmes informatiques - IBM SERVICES CENTER",
    description: "Découvrez les machines mais aussi tous les interlocuteurs de notre société qui intéragissent avec nos services informatiques",
    description_rich_text: "Venez découvrir le métier d'administrateur systèmes ! Vous observerez comment nos administrateurs garantissent aux clients le bon fonctionnement etc.",
    employer_description_rich_text: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique.",
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_role: 'Chef magasinier',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    remote_id: '1',
    permalink: 'https://www.google.fr',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: 'IBM'
  )
  # 3eme generale API
  weeks = Week.of_previous_school_year
  InternshipOffers::Api.create!(
    employer: Users::Operator.first,
    siret: siret,
    weeks: weeks,
    first_date: weeks.first.beginning_of_week,
    last_date: weeks.last.beginning_of_week,
    sector: Sector.first,
    group: Group.is_public.first,
    is_public: false,
    title: "Découverte des métiers administratifs de l'Education nationale",
    description: "La Direction des Services de l'Education Nationale de Seine-et-Marne (DSDEN) propose des stages d'observation",
    description_rich_text: "La Direction des Services de l'Education Nationale de Seine-et-Marne (DSDEN) se compose de plusieurs services répartis sur 11 étages. Ses 240 agents  ...",
    employer_description_rich_text: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique.",
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    tutor_role: 'Chef magasinier',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    remote_id: '2',
    permalink: 'https://www.google.fr',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'Ministère de l\'Education Nationale'
  )

  # 3eme generale multi-line
  multiline_description = <<-MULTI_LINE
- Présentation des services de la direction régionale de Valenciennes (service contentieux, pôle action économique).
- Présentation de la recette interrégionale (service de perception).
- Immersion au sein d’un bureau de douane (gestion des procédures, déclarations en douane, dédouanement, contrôles des déclarations et des marchandises).
MULTI_LINE
  weeks = Week.weeks_of_school_year(school_year: SchoolYear::Base::YEAR_START)
  InternshipOffers::WeeklyFramed.create!(
    max_candidates: 5,
    max_students_per_group: 5,
    employer: Users::Employer.first,
    weeks: weeks,
    first_date: weeks.first.beginning_of_week,
    last_date: weeks.last.beginning_of_week,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Découverte des services douaniers de Valenciennes',
    description_rich_text: multiline_description,
    employer_description_rich_text: 'La douane assure des missions fiscales et de lutte contre les trafics illicites et la criminalité organisée.',
    employer_website: "http://www.prefectures-regions.gouv.fr/hauts-de-france/Region-et-institutions/Organisation-administrative-de-la-region/Les-services-de-l-Etat-en-region/Direction-interregionale-des-douanes/Direction-interregionale-des-douanes",
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    tutor_role: 'Bibliothécaire',
    street: '2 rue jean moulin',
    zipcode: '95160',
    city: 'Montmorency',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: 'Douanes Assistance Corp.'
  )
  # 3eme generale multi-line
  multiline_description = <<-MULTI_LINE
- Présentation des services de la succursale MetaBoutShop
- Présentation des principes fondamentaux du métier.
- Immersion au sein d’une équipe de gestionnaire de la boutique. Proposition de gestion de portefeuille de boutiques et de stands fictifs en fin de stage, avec les conseils du tuteur'.
MULTI_LINE
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    max_candidates: 5,
    max_students_per_group: 5,
    weeks: weeks,
    first_date: weeks.first.beginning_of_week,
    last_date: weeks.last.beginning_of_week,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Découverte du travail de gestionnaire en ligne',
    description_rich_text: multiline_description,
    employer_description_rich_text: 'Le métier de gestionnaire consiste à optimiser les ressources de la MetaBoutShop en spéculant sur des valeurs mobilières',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    tutor_role: 'Chef de service',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.verneuil[:latitude], longitude: Coordinates.verneuil[:longitude] },
    employer_name: 'MetaBoutShop'
  )
  # 3eme generale multi-line
  multiline_description = <<-MULTI_LINE
- Présentation des services de la direction régionale de la banque Acme Corp. (banque de dépôt).
- Présentation des principes secondaires du métier.
- Immersion au sein d’une équipe d'admiistrateurs de comptes de la banque. Proposition de gestion de portefeuille de clients en fin de stage, avec les conseils du tuteur'.
MULTI_LINE
  weeks = Week.weeks_of_school_year(school_year: (SchoolYear::Base::YEAR_START + 1))
  acme = InternshipOffers::WeeklyFramed.create!(
    max_candidates: 5,
    max_students_per_group: 5,
    employer: Users::Employer.first,
    weeks: weeks,
    first_date: weeks.first.beginning_of_week,
    last_date: weeks.last.beginning_of_week,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Découverte du travail de trader',
    description_rich_text: multiline_description,
    employer_description_rich_text: 'Le métier de trader consiste à optimiser les ressources de la banque Oyonnax Corp. en spéculant sur des valeurs mobilières',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    tutor_role: 'Chef de service',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.verneuil[:latitude], longitude: Coordinates.verneuil[:longitude] },
    employer_name: 'Oyonnax Corp.'
  )
end

call_method_with_metrics_tracking([:populate_internship_offers])