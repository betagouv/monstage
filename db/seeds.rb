# frozen_string_literal: true
require 'csv'

def populate_week_reference
  first_year = 2019
  last_year = Time.now.year + 1

  first_week = 1
  last_week = 53 # A 53 week exisits! https://fr.wikipedia.org/wiki/Semaine_53

  first_year.upto(last_year) do |year|
    first_week.upto(last_week) do |week| # number of the week
      if week == last_week
        Date.commercial(year, week, 1)
      end

      Week.create!(year: year, number: week)
    rescue ArgumentError
      puts "no week #{week} for year #{year}"
    rescue ActiveRecord::RecordNotUnique
      puts "week #{week} - #{year} already exists"
    end
  end
end

def populate_month_reference
  next_month = 3.years.ago.beginning_of_month
  loop do
    Month.create!(date: next_month)
    next_month = next_month.next_month
    break if next_month > 10.years.from_now
  end
end

def geo_point_factory_array(coordinates_as_array)
  type = { geo_type: 'point' }
  factory = RGeo::ActiveRecord::SpatialFactoryStore.instance
                                                   .factory(type)
  factory.point(*coordinates_as_array)
end

def populate_schools
  CSV.foreach(Rails.root.join('db/data_imports/seed-schools.csv'), headers: { col_sep: ',' }).each.with_index do |row, i|
    next if i.zero?
    school = School.find_or_create_by!(
      code_uai: row['Code UAI'],
      name: row['ETABLISSEMENT'],
      city: row['Commune'],
      department: row['Département'],
      zipcode: row['zipcode'],
      coordinates: geo_point_factory_array(JSON.parse(row['coordinates'])['coordinates'])
    )
  end
end

def populate_class_rooms
  school = find_default_school_during_test

  ClassRoom.create(name: '3e A – troisieme', school_track: :troisieme_generale, school: school)
  ClassRoom.create(name: '3e B – troisieme_prepa_metiers', school_track: :troisieme_prepa_metiers, school: school)
  ClassRoom.create(name: '3e C – troisieme_segpa', school_track: :troisieme_segpa, school: school)
  create_a_discarded_class_room
end

def create_a_discarded_class_room
  school = find_default_school_during_test

  ClassRoom.create(name: '3e D – troisieme',
                   school_track: :troisieme_generale,
                   school: school)
           .archive
end

def with_class_name_for_defaults(object)
  object.first_name ||= "user"
  object.last_name ||= object.class.name
  object.accept_terms = true
  object.confirmed_at = Time.now.utc
  object
end

def populate_operators
  Operator.create(name: "Un stage et après !",
                  website: "",
                  logo: 'Logo-un-stage-et-apres.jpg',
                  target_count: 120,
                  airtable_reporting_enabled: true,
                  airtable_link: Rails.application.credentials.dig(:air_table, :operators, :unstageetapres, :share_link),
                  airtable_id: 'shrauIKjiyi4MhWAJ')
  Operator.create(name: "JobIRL",
                  website: "",
                  logo: 'Logo-jobirl.jpg',
                  target_count: 32,
                  airtable_reporting_enabled: true,
                  airtable_link: Rails.application.credentials.dig(:air_table, :operators, :jobirl, :share_link),
                  airtable_id: 'shrEJhYILer3ZHBiV')
  Operator.create(name: "Le Réseau",
                  website: "",
                  logo: 'Logo-le-reseau.jpg',
                  target_count: 710,
                  airtable_reporting_enabled: true,
                  airtable_link: Rails.application.credentials.dig(:air_table, :operators, :lereseau, :share_link),
                  airtable_id: 'shrcTuYlB7c2znRTq')
  Operator.create(name: "Institut Télémaque",
                  website: "",
                  logo: 'Logo-telemaque.png',
                  target_count: 1200,
                  airtable_reporting_enabled: false)
  Operator.create(name: "Myfuture",
                  website: "",
                  logo: 'Logo-moidans10ans.png',
                  target_count: 1200,
                  airtable_reporting_enabled: true,
                  airtable_link: Rails.application.credentials.dig(:air_table, :operators, :myfuture, :share_link),
                  airtable_id: 'shrkmCsiBu4KpfnNJ')
  Operator.create(name: "Les entreprises pour la cité (LEPC)",
                  website: "",
                  logo: 'Logo-les-entreprises-pour-la-cite.jpg',
                  target_count: 1200,
                  airtable_reporting_enabled: true,
                  airtable_link: Rails.application.credentials.dig(:air_table, :operators, :lepc, :share_link),
                  airtable_id: 'shrKD4JKsyPi2CdOD')
  Operator.create(name: "Tous en stage",
                  website: "",
                  logo: 'Logo-tous-en-stage.jpg',
                  target_count: 1200,
                  airtable_reporting_enabled: true,
                  airtable_link: Rails.application.credentials.dig(:air_table, :operators, :tousenstage, :share_link),
                  airtable_id: 'shrXOR0CxIPE0iqwS')
  Operator.create(name: "Viens voir mon taf",
                  website: "",
                  logo: 'Logo-viens-voir-mon-taf.jpg',
                  target_count: 1200,
                  airtable_reporting_enabled: true,
                  airtable_link: Rails.application.credentials.dig(:air_table, :operators, :vvmt, :share_link),
                  airtable_id: 'shrWuRLYOmbrCQ9Or')
end

def populate_sectors
  {
    "Mode" => "b7564ac4-e184-41c4-a7a9-57233a9d244a",
    "Banque et assurance" => "6a8f813b-c338-4d4f-a4cd-99a28748b57d",
    "Audiovisuel" => "4b6427b1-b289-486d-b7ea-f33134995a99",
    "Communication" => "63d73fd3-9ca6-4838-95aa-9901896be99c",
    "Édition, librairie, bibliothèque" => "27c1d368-0846-4038-903f-d63b989e0fe4",
    "Traduction, interprétation" => "1123edde-0d77-498a-85c5-2ab3d81b3cd8",
    "Bâtiment et travaux publics (BTP)" => "ab69287d-273a-4626-b645-d98f567b22ba",
    "Comptabilité, gestion, ressources humaines" => "bfb24e1c-aebc-4451-bb4b-569ab71a814d",
    "Droit et justice" => "1711c7c8-89dc-48dd-9ae9-22bde1bd281b",
    "Enseignement" => "76f3a155-e592-4bb9-8512-358a7d9db313",
    "Recherche" => "c5db692a-2a17-403c-8151-1b3cd7dc48ba",
    "Énergie" => "af7e191a-7065-403e-844d-197e7e1e8bdb",
    "Environnement" => "1bbc6281-805e-4045-b85b-65a1479a865d",
    "Logistique et transport" => "19ccd244-5fac-4ad9-8513-7488d0980f4c",
    "Hôtellerie, restauration" => "92e5ad0c-6e30-43a4-8158-818236d01390",
    "Tourisme" => "dd9d626b-735a-4139-87b8-8c67990b97ba",
    "Agroéquipement" => "0b91687a-f3cc-4cd1-bfb5-b9f03994b1bd",
    "Automobile" => "f3733e9c-f33c-4c33-9903-baf9c8e2d2fb",
    "Construction aéronautique, ferroviaire et navale" => "ee0e9e5c-f19e-4be8-9399-2cff4f4e5ca5",
    "Électronique" => "1ce6aa62-6d91-41e5-9135-ce97e7c94a46",
    "Industrie alimentaire" => "95776212-ddd1-466e-ba5b-089f4e2f11ac",
    "Industrie chimique" => "4974df57-0111-492d-ab60-3bfdad10733d",
    "Maintenance" => "0f51b2d6-91da-4543-a0aa-d49a7be3d249",
    "Mécanique" => "4ee8bd54-7b5b-4ae9-9603-78f303d5aea8",
    "Verre, béton, céramique" => "463578f1-b371-4466-a13f-b0e99f783391",
    "Informatique et réseaux" => "bfd92448-5eae-4d99-ae2c-67fffc8fec69",
    "Jeu vidéo" => "be4bab4d-09ed-4205-bca1-1047da0500f8",
    "Commerce et distribution" => "ae267ff2-76d5-460a-9a41-3b820c392149",
    "Marketing, publicité" => "811621f0-e2d1-4c32-a406-5b45979d7c6d",
    "Médical" => "1aae3b41-1394-4109-83cf-17214e1aefdd",
    "Paramédical" => "89946839-8e18-4087-b48d-e6ee5f7d8480",
    "Social" => "d5a7ec0f-5f9c-44cb-add0-66465b4e7d3c",
    "Sport" => "01d06ada-55be-4ebf-8ad2-2666e7a7f521",
    "Agriculture" => "76de34d3-b524-456d-bc91-92e133cdab2b",
    "Filiere bois" => "aa658f28-a9ac-4a29-976f-a528c994f37a",
    "Architecture, urbanisme et paysage" => "1ee1b11c-97ca-4b7e-a6fb-afe404f24954",
    "Armée - Défense" => "4c0e0937-d7af-4b1c-998c-c1b1d628e3a3",
    "Sécurité" => "ec4ce411-f8fd-4690-b51f-3290ffd069e0",
    "Art et design" => "c1f72076-43fb-44ae-a811-d55eccf15c08",
    "Artisanat d'art" => "1ce60ecc-273d-4c73-9b1a-2f5ee14e1bc6",
    "Arts du spectacle" => "055b7580-c979-480f-a026-e94c8b8dc46e",
    "Culture et patrimoine" => "c76e6364-7257-473c-89aa-c951141810ce"
  }.map do |sector_name, sector_uuid|
    Sector.create!(name: sector_name, uuid: sector_uuid)
  end
end

def populate_groups
  Group.create!(name: 'PUBLIC GROUP', is_public: true, is_paqte: false)
  Group.create!(name: 'PRIVATE GROUP', is_public: false, is_paqte: false)
  Group.create!(name: 'Carrefour', is_public: false, is_paqte: true)
  Group.create!(name: 'Engie', is_public: false, is_paqte: true)
  Group.create!(name: 'Ministère de la Justice', is_public: true, is_paqte: false)
end

def populate_users
  troisieme_generale_class_room = ClassRoom.find_by(school_track: :troisieme_generale)
  troisieme_segpa_class_room = ClassRoom.find_by(school_track: :troisieme_segpa)
  with_class_name_for_defaults(Users::Employer.new(email: 'employer@ms3e.fr', password: 'review')).save!
  with_class_name_for_defaults(Users::God.new(email: 'god@ms3e.fr', password: 'review')).save!
  with_class_name_for_defaults(Users::Operator.new(email: 'operator@ms3e.fr', password: 'review', operator: Operator.first)).save!
  Operator.reportable.map do |operator|
    with_class_name_for_defaults(Users::Operator.new(email: "#{operator.name.parameterize}@ms3e.fr", password: 'review', operator: operator)).save!
  end
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'school_manager', email: "school_manager@#{find_default_school_during_test.email_domain_name}", password: 'review', school: find_default_school_during_test)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'main_teacher', class_room: troisieme_generale_class_room, email: 'main_teacher@ms3e.fr', password: 'review', school: find_default_school_during_test)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'main_teacher', class_room: troisieme_segpa_class_room, email: 'main_teacher_segpa@ms3e.fr', password: 'review', school: find_default_school_during_test)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'other', email: 'other@ms3e.fr', password: 'review', school: find_default_school_during_test)).save!

  statistician_email = 'statistician@ms3e.fr'
  ministry_statistician = 'ministry_statistician@ms3e.fr'
  last_public_group = Group.where(is_public: true).last

  EmailWhitelists::Statistician.create!(email: statistician_email, zipcode: 75)
  EmailWhitelists::Ministry.create!(email: ministry_statistician, group_id: last_public_group.id)
  with_class_name_for_defaults(Users::Statistician.new(email: statistician_email, password: 'review')).save!
  with_class_name_for_defaults(Users::MinistryStatistician.new(email: ministry_statistician, password: 'review', ministry: last_public_group)).save!

  with_class_name_for_defaults(Users::Student.new(email: 'student@ms3e.fr',       password: 'review', first_name: 'Abdelaziz', last_name: 'Benzedine', school: find_default_school_during_test, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'student_other@ms3e.fr', password: 'review', first_name: 'Mohammed', last_name: 'Rivière', school: find_default_school_during_test, class_room: ClassRoom.troisieme_generale.first, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'teacher', email: 'teacher@ms3e.fr', password: 'review', school: find_default_school_during_test)).save!
end

def populate_students
  class_room_3e_generale     = ClassRoom.first
  class_room_3e_prepa_metier = ClassRoom.second
  class_room_3e_segpa        = ClassRoom.third
  class_room_archived        = ClassRoom.fourth

  school = class_room_3e_generale.school

  # sans classe
  with_class_name_for_defaults(Users::Student.new(email: 'enzo@ms3e.fr', password: 'review', first_name: 'Enzo', last_name: 'Mesnard', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 3.days.ago)).save!
  # 3e générale
  with_class_name_for_defaults(Users::Student.new(email: 'abdelaziz@ms3e.fr', password: 'review', first_name: 'Mohsen', last_name: 'Yahyaoui', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago, class_room: class_room_3e_generale)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'alfred@ms3e.fr', password: 'review', first_name: 'Alfred', last_name: 'Cali', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago, class_room: class_room_3e_generale)).save!
  # 3e prepa métier
  with_class_name_for_defaults(Users::Student.new(email: 'louis@ms3e.fr', password: 'review', first_name: 'Louis', last_name: 'Tardieu', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago, class_room: class_room_3e_prepa_metier)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'leon@ms3e.fr', password: 'review', first_name: 'Leon', last_name: 'Dupre', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago, class_room: class_room_3e_prepa_metier)).save!
  # 3e segpa
  with_class_name_for_defaults(Users::Student.new(email: 'martine@ms3e.fr', password: 'review',first_name: 'Martine', last_name: 'Perchot',  school: school, birth_date: 14.years.ago, gender: 'f', confirmed_at: 2.days.ago, class_room: class_room_3e_segpa)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'alexandrine@ms3e.fr', password: 'review', first_name: 'Alexandrine', last_name: 'Gidonot',  school: school, birth_date: 14.years.ago, gender: 'f', confirmed_at: 2.days.ago, class_room: class_room_3e_segpa)).save!
  # archived class_room
  with_class_name_for_defaults(Users::Student.new(email: 'frederique@ms3e.fr', password: 'review', first_name: 'Frédérique', last_name: 'Dupin',  school: school, birth_date: 14.years.ago, gender: 'f', confirmed_at: 2.days.ago, class_room: class_room_archived)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'karima@ms3e.fr', password: 'review', first_name: 'Karima', last_name: 'Belgarde',  school: school, birth_date: 14.years.ago, gender: 'f', confirmed_at: 2.days.ago, class_room: class_room_archived)).save!
end

def populate_internship_offers
  # 3eme_generale: public sector
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    weeks: Week.selectable_on_school_year,
    sector: Sector.first,
    group: Group.is_paqte.first,
    is_public: false,
    title: 'Stage assistant.e ressources humaines - Service des recrutements',
    description_rich_text: 'Vous assistez la responsable de secteur dans la gestion du recrutement des intervenant.e.s à domicile et la gestion des contrats de celles et ceux en contrat avec des particulier-employeurs.',
    employer_description_rich_text: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile pour la garde de leurs enfants de 0 à 16 ans.",
    employer_website: 'http://www.dtpm.fr/',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: Group.is_paqte.first.name,
    school_track: :troisieme_generale
  )
  InternshipOffers::WeeklyFramed.create!(
      employer: Users::Employer.first,
      weeks: [].concat(Week.selectable_on_school_year[0..1], Week.selectable_on_school_year[3..5]),
      sector: Sector.first,
      group: Group.is_paqte.first,
      is_public: false,
      title: 'Stage avec deux segments de date, bugfix',
      description_rich_text: 'Scanner metrology is a unique field where software engineers combine their talents in physics and programming expertise. Our scanner metrology software coordinates powerful mechatronic modules, providing the speed and precision to pattern silicon wafers with nanometer accuracy.'.truncate(249),
      employer_description_rich_text: "Scanner metrology is a unique field where software engineers combine their talents in physics and programming expertise. Our scanner metrology software coordinates powerful mechatronic modules, providing the speed and precision to pattern silicon wafers with nanometer accuracy.".truncate(249),
      employer_website: 'https://www.asml.com/en/careers',
      tutor_name: 'John smith',
      tutor_email: 'fourcade.m@gmail.com',
      tutor_phone: '+33637607756',
      street: '128 rue brancion',
      zipcode: '75015',
      city: 'paris',
      coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
      employer_name: Group.is_paqte.first.name,
      school_track: :troisieme_generale
    )

    # 3eme generale public
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    weeks: Week.selectable_on_school_year,
    sector: Sector.second,
    group: Group.is_public.last,
    is_public: true,
    title: "Observation du métier de chef de service - Ministère",
    description: "Découvrez les réunions et comment se prennent les décisions au plus haut niveau mais aussi tous les interlocuteurs de notre société qui intéragissent avec nos services ",
    description_rich_text: "Venez découvrir le métier de chef de service ! Vous observerez comment nos administrateurs garantissent aux usagers l'exercice de leur droits, tout en respectant leurs devoirs.",
    employer_description_rich_text: "De multiples méthodes de travail et de prises de décisions seront observées",
    tutor_name: 'Etienne Weil',
    tutor_email: 'etienne@free.fr',
    tutor_phone: '+33637697756',
    street: '18 rue Damiens',
    zipcode: '75012',
    city: 'paris',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: Group.is_public.last.name,
    school_track: :troisieme_generale
  )

  # 3eme_generale-2019:
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    weeks: Week.weeks_of_school_year(school_year: SchoolYear::Base::YEAR_START),
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Stage editeur - A la recherche du temps passé par les collaborateurs',
    description_rich_text: 'Vous assistez la responsable de secteur dans la gestion des projets internes touchant à la gestion des contrats.',
    employer_description_rich_text: "Du Temps pour moi est une agence mandataire de garde d'enfants à domicile. Notre activité consister à aider les familles de la métropole lilloise à trouver leur intervenant(e) à domicile pour la garde de leurs enfants de 0 à 16 ans.",
    employer_website: 'http://www.dtpm.fr/',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637677756',
    street: '129 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: 'Editegis',
    school_track: :troisieme_generale
  )
  # 3eme generale API
  InternshipOffers::Api.create!(
    employer: Users::Operator.first,
    weeks: Week.selectable_on_school_year,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: "Observation du métier d'Administrateur de systèmes informatiques - IBM SERVICES CENTER",
    description: "Découvrez les machines mais aussi tous les interlocuteurs de notre société qui intéragissent avec nos services informatiques",
    description_rich_text: "Venez découvrir le métier d'administrateur systèmes ! Vous observerez comment nos administrateurs garantissent aux clients le bon fonctionnement de toutes leurs technologies informatique depuis nos locaux et comment ils arrivent, tous les jours, à gérer en équipe, des bases de données, de la virtualisation, des applications etc.",
    employer_description_rich_text: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique. C'est à dire que nous assurons à nos clients que leurs serveurs et leurs technologies variées fonctionnent en permanence.",
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    remote_id: '1',
    permalink: 'https://www.google.fr',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: 'IBM',
  )
  # 3eme generale API
  InternshipOffers::Api.create!(
    employer: Users::Operator.first,
    weeks: Week.of_previous_school_year,
    sector: Sector.first,
    group: Group.is_public.first,
    is_public: false,
    title: "Découverte des métiers administratifs de l'Education nationale",
    description: "La Direction des Services de l'Education Nationale de Seine-et-Marne (DSDEN) propose des stages d'observation",
    description_rich_text: "La Direction des Services de l'Education Nationale de Seine-et-Marne (DSDEN) se compose de plusieurs services répartis sur 11 étages. Ses 240 agents exercent des métiers variés et complémentaires. Les activités et compétences à découvrir lors du stage sont diverses : secrétariat, accueil et logistique, ressources humaines, juridiques, financières, statistiques ...",
    employer_description_rich_text: "Le centre de service IBM de Lille délivre des services d'infrastructure informatique. C'est à dire que nous assurons à nos clients que leurs serveurs et leurs technologies variées fonctionnent en permanence.",
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    remote_id: '2',
    permalink: 'https://www.google.fr',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'Ministère de l\'Education Nationale',
  )

  # 3eme prépa métier multi-line
  multiline_description = <<-MULTI_LINE
- Présentation des services de la direction régionale de Valenciennes (service contentieux, pôle action économique).
- Présentation de la recette interrégionale (service de perception).
- Immersion au sein d’un bureau de douane (gestion des procédures, déclarations en douane, dédouanement, contrôles des déclarations et des marchandises), d’un bureau de douane spécialisé dans les produits énergétiques et d’un bureau de douanes fiscalité et contributions indirectes.
MULTI_LINE
  InternshipOffers::FreeDate.create!(
    employer: Users::Employer.first,
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
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: 'Douanes Assistance Corp.',
    school_track: :troisieme_prepa_metiers
  )
  # 3eme segpa multi-line
  multiline_description = <<-MULTI_LINE
- Présentation des services de la direction régionale de la banque Oyonnax Corp. (service intelligence économique, pôle ingénierie financière).
- Présentation des principes fondamentaux du métier.
- Immersion au sein d’une équipe de trader de la banque. Proposition de gestion de portefeuille fictif en fin de stage, avec les conseils du tuteur'.
MULTI_LINE
  InternshipOffers::FreeDate.create!(
    employer: Users::Employer.first,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Découverte du travail de trader en ligne',
    description_rich_text: multiline_description,
    employer_description_rich_text: 'Le métier de trader consiste à optimiser les ressources de la banque Oyonnax Corp. en spéculant sur des valeurs mobilières',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.verneuil[:latitude], longitude: Coordinates.verneuil[:longitude] },
    employer_name: 'Oyonnax Corp.',
    school_track: :troisieme_segpa
  )
  # 3eme segpa multi-line
  multiline_description = <<-MULTI_LINE
- Présentation des services de la direction régionale de la banque Acme Corp. (banque de dépôt).
- Présentation des principes secondaires du métier.
- Immersion au sein d’une équipe d'admiistrateurs de comptes de la banque. Proposition de gestion de portefeuille de clients en fin de stage, avec les conseils du tuteur'.
MULTI_LINE
  acme = InternshipOffers::FreeDate.create!(
    employer: Users::Employer.first,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Découverte du travail de gestionnaire de compte',
    description_rich_text: multiline_description,
    employer_description_rich_text: 'Le métier de trader consiste à optimiser les ressources de la banque Oyonnax Corp. en spéculant sur des valeurs mobilières',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.verneuil[:latitude], longitude: Coordinates.verneuil[:longitude] },
    employer_name: 'Oyonnax Corp.',
    school_track: :troisieme_segpa,
    created_at: Date.today - 1.year,
    updated_at: Date.today - 1.year
  )
  school_year = SchoolYear::Floating.new(date: Date.today - 1.year)
  acme.update_columns(
    last_date: school_year.end_of_period,
    first_date: school_year.beginning_of_period
  )
end

def find_default_school_during_test
  # School.find_by_code_uai("0781896M") # school at mantes lajolie, school name : Pasteur.
  School.find_by_code_uai("0752694W") # school at Paris, school name : Camille Claudel.
end

# used for application
def populate_school_weeks
  school = find_default_school_during_test
  # used for application
  school.weeks = Week.selectable_on_school_year.limit(5) + Week.from_date_for_current_year(from: Date.today).limit(1)
  school.save!

  # used to test matching between internship_offers.weeks and existing school_weeks
  other_schools = School.nearby(latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude], radius: 60_000).limit(4)
                        .where.not(id: school.id)
  other_schools.each.with_index do |another_school, i|
    another_school.update!(weeks: Week.selectable_on_school_year.limit(i+1))
  end
end

def populate_applications
  trois_gene_studs = Users::Student.joins(:class_room)
                                   .where('class_rooms.school_track = ?', :troisieme_generale)
                                   .to_a
                                   .shuffle
                                   .first(3)
  troisieme_generale_offers = InternshipOffers::WeeklyFramed.where(school_track: :troisieme_generale)
  puts "every 3e generale offers receives an application first 3e generale stud"
  troisieme_generale_offers.each do |io_trois_gene|
    InternshipApplications::WeeklyFramed.create!(
      aasm_state: :submitted,
      submitted_at: 10.days.ago,
      student: trois_gene_studs.first,
      motivation: 'Au taquet',
      internship_offer: io_trois_gene,
      internship_offer_week: io_trois_gene.internship_offer_weeks.sample
    )
  end

  puts "second 3e generale offer receive an approval --> second 3e generale stud"
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :approved,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: trois_gene_studs.second,
    motivation: 'Au taquet',
    internship_offer: troisieme_generale_offers.first,
    internship_offer_week: troisieme_generale_offers.first.internship_offer_weeks.sample
  )

  puts  "third 3e generale stud cancels his application to first offer"
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :canceled_by_student,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: trois_gene_studs.third,
    motivation: 'Au taquet',
    internship_offer: troisieme_generale_offers.first,
    internship_offer_week: troisieme_generale_offers.second.internship_offer_weeks.sample
  )
  puts  "second 3e generale stud is canceled by employer of last internship_offer"
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :canceled_by_employer,
    submitted_at: 10.days.ago,
    approved_at: 3.days.ago,
    student: trois_gene_studs.second,
    motivation: 'Parce que ma société n\'a pas d\'encadrant cette semaine là',
    internship_offer: troisieme_generale_offers.last,
    internship_offer_week: troisieme_generale_offers.last.internship_offer_weeks.sample
  )
  puts  "third 3e generale stud is rejected of last internship_offer"
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :rejected,
    submitted_at: 8.days.ago,
    approved_at: 3.days.ago,
    student: trois_gene_studs.third,
    motivation: 'Parce que ma société n\'a pas d\'encadrant cette semaine là',
    internship_offer: troisieme_generale_offers.last,
    internship_offer_week: troisieme_generale_offers.last.internship_offer_weeks.sample
  )
end

def populate_aggreements
  application = InternshipApplication.find_by(aasm_state: 'approved')
  FactoryBot.create(
    :internship_agreement,
    internship_application: application,
    employer_accept_terms: true
  )
  # 3eme segpa multi-line
  multiline_description = <<-MULTI_LINE
- Présentation des services de la direction régionale de la banque Oyonnax Corp. (service intelligence économique, pôle ingénierie financière).
- Présentation des principes fondamentaux du métier.
- Immersion au sein d’une équipe de trader de la banque. Proposition de gestion de portefeuille fictif en fin de stage, avec les conseils du tuteur'.
MULTI_LINE
  InternshipOffers::FreeDate.create!(
    employer: Users::Employer.first,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Découverte du travail de trader en ligne',
    description_rich_text: multiline_description,
    employer_description_rich_text: 'Le métier de trader consiste à optimiser les ressources de la banque Oyonnax Corp. en spéculant sur des valeurs mobilières',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: Coordinates.paris[:latitude], longitude: Coordinates.paris[:longitude] },
    employer_name: 'Oyonnax Corp.',
    school_track: :troisieme_segpa
  )
end

def populate_internship_weeks
  manager = Users::SchoolManagement.find_by(role: 'school_manager')
  school = manager.school
  school.week_ids = Week.selectable_on_school_year.pluck(:id)
end


ActiveSupport::Notifications.subscribe /seed/ do |event|
  puts "#{event.name} done! #{event.duration}"
end

def call_method_with_metrics_tracking(methods)
  methods.each do |method_name|
    ActiveSupport::Notifications.instrument "seed.#{method_name}" do
      send(method_name)
    end
  end
end

if Rails.env == 'review' || Rails.env.development?
  require 'factory_bot_rails'
  call_method_with_metrics_tracking([
    :populate_month_reference,
    :populate_week_reference,
    :populate_schools,
    :populate_class_rooms,
    :populate_operators,
    :populate_sectors,
    :populate_groups,
    :populate_users,
    :populate_internship_offers,
    :populate_students,
    :populate_school_weeks,
    :populate_applications,
    :populate_aggreements
  ])
  School.update_all(updated_at: Time.now)
end
