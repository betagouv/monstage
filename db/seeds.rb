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

def siret
  siret = FFaker::CompanyFR.siret
  siret.gsub(/[^0-9]/, '')
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
  school_file_name = Rails.env == 'review' ? 'seed-schools-light.csv' : 'seed-schools.csv'
  CSV.foreach(Rails.root.join("db/data_imports/#{school_file_name}"), headers: { col_sep: ',' }).each.with_index do |row, i|
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

  ClassRoom.create(name: '3e A', school: school)
  ClassRoom.create(name: '3e B', school: school)
  ClassRoom.create(name: '3e C', school: school)
end

def with_class_name_for_defaults(object)
  object.first_name ||= FFaker::NameFR.first_name
  object.last_name ||= "#{FFaker::NameFR.last_name}-#{Presenters::UserManagementRole.new(user: object).role}"
  object.accept_terms = true
  object.confirmed_at = Time.now.utc
  object.current_sign_in_at = 2.days.ago
  object.last_sign_in_at = 12.days.ago
  object
end

def populate_operators
  Operator.create(name: "Un stage et après !",
                  website: "",
                  logo: 'Logo-un-stage-et-apres.jpg',
                  target_count: 120,
                  airtable_reporting_enabled: true,
                  airtable_link: ENV['AIRTABLE_SHARE_LINK_TEST'],
                  airtable_id: ENV['AIRTABLE_EMBEDDED_ID_TEST'])
  # this one is for test
  Operator.create(name: "JobIRL",
                  website: "",
                  logo: 'Logo-jobirl.jpg',
                  target_count: 32,
                  airtable_reporting_enabled: true,
                  airtable_link: ENV['AIRTABLE_SHARE_LINK_TEST'],
                  airtable_id: ENV['AIRTABLE_EMBEDDED_ID_TEST'])
  Operator.create(name: "Le Réseau",
                  website: "",
                  logo: 'Logo-le-reseau.jpg',
                  target_count: 710,
                  airtable_reporting_enabled: true,
                  airtable_link: ENV['AIRTABLE_SHARE_LINK_TEST'],
                  airtable_id: ENV['AIRTABLE_EMBEDDED_ID_TEST'])
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
                  airtable_link: ENV['AIRTABLE_SHARE_LINK_TEST'],
                  airtable_id: ENV['AIRTABLE_EMBEDDED_ID_TEST'])
  Operator.create(name: "Les entreprises pour la cité (LEPC)",
                  website: "",
                  logo: 'Logo-les-entreprises-pour-la-cite.jpg',
                  target_count: 1200,
                  airtable_reporting_enabled: true,
                  airtable_link: ENV['AIRTABLE_SHARE_LINK_TEST'],
                  airtable_id: ENV['AIRTABLE_EMBEDDED_ID_TEST'])
  Operator.create(name: "Tous en stage",
                  website: "",
                  logo: 'Logo-tous-en-stage.jpg',
                  target_count: 1200,
                  airtable_reporting_enabled: true,
                  airtable_link: ENV['AIRTABLE_SHARE_LINK_TEST'],
                  airtable_id: ENV['AIRTABLE_EMBEDDED_ID_TEST'])
  Operator.create(name: "Viens voir mon taf",
                  website: "",
                  logo: 'Logo-viens-voir-mon-taf.jpg',
                  target_count: 1200,
                  airtable_reporting_enabled: true,
                  airtable_link: ENV['AIRTABLE_SHARE_LINK_TEST'],
                  airtable_id: ENV['AIRTABLE_EMBEDDED_ID_TEST'])
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
  Group.create!(name: 'Ministère de l\'Intérieur', is_public: true, is_paqte: false)
end

def populate_users
  class_room = ClassRoom.first

  with_class_name_for_defaults(
    Users::Employer.new(
      email: 'employer@ms3e.fr',
      password: 'review',
      employer_role: 'PDG',
      phone: '+330622554144'
    )
  ).save!
  with_class_name_for_defaults(Users::God.new(email: 'god@ms3e.fr', password: 'review')).save!

  school_manager = with_class_name_for_defaults(Users::SchoolManagement.new(
    role: 'school_manager',
    email: "ce.1234567X@#{find_default_school_during_test.email_domain_name}",
    password: 'review',
    school: find_default_school_during_test,
    phone: '+330623655541'))
  school_manager.save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'main_teacher', class_room: class_room, email: "main_teacher@#{find_default_school_during_test.email_domain_name}", password: 'review', school: find_default_school_during_test)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'main_teacher', email: "main_teacher_no_class_room@#{find_default_school_during_test.email_domain_name}", password: 'review', school: find_default_school_during_test)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'other', email: "other@#{find_default_school_during_test.email_domain_name}", password: 'review', school: find_default_school_during_test)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'teacher', email: "teacher@#{find_default_school_during_test.email_domain_name}", password: 'review', school: find_default_school_during_test)).save!

  Operator.reportable.map do |operator|
    with_class_name_for_defaults(Users::Operator.new(email: "#{operator.name.parameterize}@ms3e.fr", password: 'review', operator: operator)).save!
  end
  with_class_name_for_defaults(Users::Operator.new(email: 'operator@ms3e.fr', password: 'review', operator: Operator.first)).save!

  statistician_email = 'statistician@ms3e.fr'
  ministry_statistician_email = 'ministry_statistician@ms3e.fr'
  education_statistician_email = 'education_statistician@ms3e.fr'
  last_public_groups = Group.where(is_public: true).last(2)
  EmailWhitelists::Statistician.create!(email: statistician_email, zipcode: 75)
  EmailWhitelists::EducationStatistician.create!(email: education_statistician_email, zipcode: 75)
  ministry_email_whitelist = EmailWhitelists::Ministry.create!(email: ministry_statistician_email, groups: last_public_groups)
  with_class_name_for_defaults(Users::PrefectureStatistician.new(email: statistician_email, password: 'review')).save!
  with_class_name_for_defaults(Users::EducationStatistician.new(email: education_statistician_email, password: 'review')).save!
  with_class_name_for_defaults(Users::MinistryStatistician.new(email: ministry_statistician_email, password: 'review')).save!
end

def populate_students
  class_room_1 = ClassRoom.first
  class_room_2 = ClassRoom.second
  class_room_3 = ClassRoom.third

  school = class_room_1.school

  with_class_name_for_defaults(Users::Student.new(email: 'student@ms3e.fr',       password: 'review', first_name: 'Abdelaziz', last_name: 'Benzedine', school: find_default_school_during_test, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'student_other@ms3e.fr', password: 'review', first_name: 'Mohammed', last_name: 'Rivière', school: find_default_school_during_test, class_room: ClassRoom.first, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago)).save!
  # sans classe
  with_class_name_for_defaults(Users::Student.new(email: 'enzo@ms3e.fr', password: 'review', first_name: 'Enzo', last_name: 'Clerc', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 3.days.ago)).save!
  
  5.times { with_class_name_for_defaults(student_maker(school: school, class_room: class_room_1)).save! }
  
  2.times { with_class_name_for_defaults(student_maker(school: school, class_room: class_room_2)).save! }
  with_class_name_for_defaults(Users::Student.new(email: 'louis@ms3e.fr', password: 'review', first_name: 'Louis', last_name: 'Tardieu', school: school, birth_date: 14.years.ago, gender: 'np', confirmed_at: 2.days.ago, class_room: class_room_2)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'leon@ms3e.fr', password: 'review', first_name: 'Leon', last_name: 'Luanco', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago, class_room: class_room_2)).save!
  
  2.times { with_class_name_for_defaults(student_maker(school: school, class_room: class_room_3)).save! }
  with_class_name_for_defaults(Users::Student.new(email: 'raphaelle@ms3e.fr', password: 'review',first_name: 'Raphaëlle', last_name: 'Mesnard',  school: school, birth_date: 14.years.ago, gender: 'f', confirmed_at: 2.days.ago, class_room: class_room_3)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'alexandrine@ms3e.fr', password: 'review', first_name: 'Alexandrine', last_name: 'Chotin',  school: school, birth_date: 14.years.ago, gender: 'f', confirmed_at: 2.days.ago, class_room: class_room_3)).save!
end

def student_maker (school: ,class_room: )
  first_name = FFaker::NameFR.first_name
  first_name = 'Kilian' if first_name.include?(' ')
  last_name = FFaker::NameFR.unique.last_name
  last_name = 'Ploquin' if last_name.include?(' ')
  email = "#{first_name}.#{last_name}@ms3e.fr"
  Users::Student.new(
    first_name: first_name,
    last_name: last_name,
    email: email,
    password: 'review',
    school: school,
    birth_date: 14.years.ago,
    gender: (['m']*4 + ['f']*4 + ['np']).shuffle.first,
    confirmed_at: 2.days.ago,
    class_room: class_room
  )
end

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
  students = Users::Student.all
  offers = InternshipOffers::WeeklyFramed.all
  puts "every 3e generale offers receives an application from first 3e generale stud"
  offers.first(4).each do |offer|
    if offer.id.to_i.even?
      InternshipApplications::WeeklyFramed.create!(
        aasm_state: :submitted,
        submitted_at: 10.days.ago,
        student: students.first,
        motivation: 'Au taquet',
        internship_offer: offer,
        week: offer.internship_offer_weeks.sample.week
      )
    else
      InternshipApplications::WeeklyFramed.create!(
        aasm_state: :drafted,
        submitted_at: 10.days.ago,
        student: students.first,
        motivation: 'Au taquet',
        internship_offer: offer,
        week: offer.internship_offer_weeks.sample.week
      )
    end
  end
  #-----------------
  # 2nd student [1 approved, 1 canceled_by_employer]
  #-----------------
  puts "second 3e generale offer receive an approval --> second 3e generale stud"
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :approved,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: students.second,
    motivation: 'Au taquet',
    internship_offer: offers.first,
    week: offers.first.internship_offer_weeks.first.week
  )

  puts  "second 3e generale stud is canceled by employer of last internship_offer"
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :canceled_by_employer,
    submitted_at: 10.days.ago,
    approved_at: 3.days.ago,
    canceled_at: 1.day.ago,
    student: students.second,
    motivation: 'Parce que ma société n\'a pas d\'encadrant cette semaine là',
    internship_offer: offers.second,
    week: offers.first.internship_offer_weeks.first.week
  )
  #-----------------
  # third student [1 approved, 1 canceled_by_student]
  #-----------------
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :approved,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: students.third,
    motivation: 'Au taquet',
    internship_offer: offers.third,
    week: offers.first.internship_offer_weeks.second.week
  )
  puts  "third 3e generale stud cancels his application to first offer"
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :canceled_by_student,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    canceled_at: 1.day.ago,
    student: students.third,
    motivation: 'Au taquet',
    internship_offer: offers.fourth,
    week: offers.second.internship_offer_weeks.second.week
  )
  #-----------------
  # 4th student [1 approved]
  #-----------------
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :approved,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: students[4],
    motivation: 'Au taquet',
    internship_offer: offers.fourth,
    week: offers.first.internship_offer_weeks.third.week
  )
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :approved,
    submitted_at: 9.days.ago,
    approved_at: 3.days.ago,
    student: students[5],
    motivation: 'Assez motivé pour ce stage',
    internship_offer: offers.fifth,
    week: offers.fifth.internship_offer_weeks.third.week
  )
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :approved,
    submitted_at: 19.days.ago,
    approved_at: 13.days.ago,
    student: students[3],
    motivation: 'motivé moyennement pour ce stage, je vous préviens',
    internship_offer: offers[5],
    week: offers[5].internship_offer_weeks.first.week
  )
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :approved,
    submitted_at: 29.days.ago,
    approved_at: 23.days.ago,
    student: students[2],
    motivation: 'motivé moyennement pour ce stage, je vous préviens',
    internship_offer: offers[6],
    week: offers[6].internship_offer_weeks.second.week
  )
  # InternshipApplications::WeeklyFramed.create!(
  #   aasm_state: :approved,
  #   submitted_at: 29.days.ago,
  #   approved_at: 23.days.ago,
  #   student: students[8],
  #   motivation: 'motivé moyennement pour ce stage, je vous préviens',
  #   internship_offer: offers[7],
  #   week: offers[7].internship_offer_weeks.second.week
  # )
end

# def populate_internship_weeks
#   manager = Users::SchoolManagement.find_by(role: 'school_manager')
#   school = manager.school
#   school.week_ids = Week.selectable_on_school_year.pluck(:id)
# end

def populate_agreements
  troisieme_applications_offers = InternshipApplications::WeeklyFramed.approved
  agreement_0 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[0].internship_offer.employer)
                                                    .new_from_application(troisieme_applications_offers[0])
  agreement_0.school_manager_accept_terms = true
  agreement_0.employer_accept_terms = false
  agreement_0.aasm_state = :draft
  agreement_0.save!

  agreement_1 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[1].internship_offer.employer)
                                                    .new_from_application(troisieme_applications_offers[1])
  agreement_1.school_manager_accept_terms = true
  agreement_1.employer_accept_terms = false
  agreement_1.aasm_state = :started_by_school_manager
  agreement_1.save!

  agreement_2 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[2].internship_offer.employer)
                                                    .new_from_application(troisieme_applications_offers[2])
  agreement_2.school_manager_accept_terms = false
  agreement_2.employer_accept_terms = true
  agreement_2.aasm_state = :completed_by_employer
  agreement_2.save!

  agreement_3 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[3].internship_offer.employer)
                                                    .new_from_application(troisieme_applications_offers[3])
  agreement_3.school_manager_accept_terms = true
  agreement_3.employer_accept_terms = true
  agreement_3.aasm_state = :validated
  agreement_3.save!

  agreement_4 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[4].internship_offer.employer)
                                                    .new_from_application(troisieme_applications_offers[4])
  agreement_4.school_manager_accept_terms = true
  agreement_4.employer_accept_terms = true

  agreement_4.aasm_state = :signatures_started
  agreement_4.save!

  agreement_5 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[5].internship_offer.employer)
                                                    .new_from_application(troisieme_applications_offers[5])
  agreement_5.school_manager_accept_terms = true
  agreement_5.employer_accept_terms = true
  agreement_5.aasm_state = :signed_by_all
  agreement_5.save!

  Signature.new(
    internship_agreement_id: agreement_4.id,
    user_id: agreement_4.school_manager.id,
    signatory_role: 'school_manager',
    signatory_ip: FFaker::Internet.ip_v4_address,
    signature_phone_number: agreement_4.school_manager.phone,
    signature_date: 1.day.ago
  ).save!
  Signature.new(
    signatory_ip: FFaker::Internet.ip_v4_address,
    internship_agreement_id: agreement_5.id,
    user_id: agreement_5.school_manager.id,
    signature_phone_number: agreement_5.school_manager.phone,
    signatory_role: 'school_manager',
    signature_date: 1.day.ago
  ).save!
  Signature.new(
    signatory_ip: FFaker::Internet.ip_v4_address,
    internship_agreement_id: agreement_5.id,
    user_id: agreement_5.employer.id,
    signature_phone_number: agreement_5.employer.phone,
    signatory_role: 'employer',
    signature_date: 1.day.ago
  ).save!
end

def populate_airtable_records
  (25..50).to_a.shuffle.first.times do |n|
    AirTableRecord.create!(make_airtable_single_record)
  end
end

def make_airtable_single_record
  is_public = [true, false].shuffle.first
  nb_spot_available =  (30..50).to_a.shuffle.first
  nb_spot_used =  nb_spot_available - (0..7).to_a.shuffle.first
  nb_spot_male = (1..nb_spot_used).to_a.shuffle.first
  group_id = Group.where(is_public: is_public).shuffle.first.id
  random_week = nb_spot_available.even? ? Week.of_previous_school_year : Week.selectable_for_school_year(school_year: SchoolYear::Current.new)
  {
    remote_id: make_airtable_rec_id,
    is_public: is_public,
    nb_spot_available: nb_spot_available,
    nb_spot_used: nb_spot_used,
    nb_spot_male: nb_spot_male,
    nb_spot_female: nb_spot_used - nb_spot_male,
    department_name: Department::MAP.values.shuffle.first,
    internship_offer_type: AirTableRecord::INTERNSHIP_OFFER_TYPE.values.shuffle.first,
    comment: nil,
    school_id: School.all.shuffle.first.id,
    group_id: group_id,
    sector_id: Sector.all.shuffle.first.id,
    week_id: random_week.to_a.shuffle.first.id,
    operator_id: Operator.all.to_a.shuffle.first.id,
    created_by: 'tech@monstagedetroisieme.fr'
  }
end

ActiveSupport::Notifications.subscribe /seed/ do |event|
  puts "#{event.name} done! #{event.duration}"
end

def make_airtable_rec_id
  az = ('a'..'z').to_a + ('A'..'Z').to_a
  digits = (0..9).to_a
  chars = []
  2.times{ |i| chars << digits.shuffle.first }
  12.times{ |i| chars << az.shuffle.first }
  "rec#{chars.shuffle.join('')}"
end

def call_method_with_metrics_tracking(methods)
  methods.each do |method_name|
    ActiveSupport::Notifications.instrument "seed.#{method_name}" do
      send(method_name)
    end
  end
end

def prevent_sidekiq_to_run_job_after_seed_loaded
  Sidekiq.redis do |redis_con|
    redis_con.flushall
  end
end

if Rails.env == 'review' || Rails.env.development?
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
    :populate_agreements,
    :populate_airtable_records
  ])
  School.update_all(updated_at: Time.now)
  prevent_sidekiq_to_run_job_after_seed_loaded
  Services::CounterManager.reset_internship_offer_counters
  Services::CounterManager.reset_internship_offer_weeks_counter
end
