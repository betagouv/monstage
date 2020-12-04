# frozen_string_literal: true
require 'csv'

# school only exists a paris/bdx
class Coordinates
  def self.paris
    { latitude: 48.866667, longitude: 2.333333 }
  end

  def self.bordeaux
    { latitude: 44.837789, longitude: -0.57918 }
  end
end

def populate_week_reference
  first_year = 2019
  last_year = 2050

  first_week = 1
  last_week = 53 # A 53 week exisits! https://fr.wikipedia.org/wiki/Semaine_53

  first_year.upto(last_year) do |year|
    first_week.upto(last_week) do |week| # number of the week
      if week == last_week
        Date.commercial(year, week, 1)
        puts "Special year #{year}, this one have 53 weeks"
      end

      Week.create!(year: year, number: week)
    rescue ArgumentError
      puts "no week #{week} for year #{year}"
    rescue ActiveRecord::RecordNotUnique
      puts "week #{week} - #{year} already exists"
    end
  end
end

def populate_schools
  # ActiveRecord::Base.transaction do
    CSV.foreach(Rails.root.join('db/data_imports/college-rep-plus.csv'), headers: { col_sep: ',' }).each.with_index do |row, i|
      next if i.zero?
      school = School.find_or_create_by!(
        code_uai: row['Code UAI'],
        name: row['ETABLISSEMENT'],
        city: row['Commune'],
        department: row['Département'],
        zipcode: '75015',
        coordinates: geo_point_factory(
            **([1,2].shuffle.first == 1 ?
               Coordinates.paris :
               Coordinates.bordeaux)
        )
      )
    end
  # end
end

def populate_class_rooms
  school = School.first
  school_manager = FactoryBot.create(:school_manager, school: school)
  ClassRoom.create(name: '3e A – troisieme_generale', school_track: :troisieme_generale, school: school)
  ClassRoom.create(name: '3e B – troisieme_prepa_metier', school_track: :troisieme_prepa_metier, school: school)
  ClassRoom.create(name: '3e C – troisieme_segpa', school_track: :troisieme_segpa, school: school)
  ClassRoom.create(name: '2nd 1 - bac_pro', school_track: :bac_pro, school: school)
end

def with_class_name_for_defaults(object)
  object.first_name ||= "user"
  object.last_name ||= object.class.name
  object.accept_terms = true
  object.confirmed_at = Time.now.utc
  object
end

def populate_operators
  Operator.create!(name: 'MS3E-OPERATOR-1')
  Operator.create!(name: 'MS3E-OPERATOR-2')
end

def populate_sectors
  Sector.create!(name: 'REVIEW-SECTOR-1')
  Sector.create!(name: 'REVIEW-SECTOR-2')
end

def populate_groups
  Group.create!(name: 'PUBLIC GROUP', is_public: true)
  Group.create!(name: 'PRIVATE GROUP', is_public: false)
end

def populate_users
  troisieme_generale_class_room = ClassRoom.find_by(school_track: :troisieme_generale)
  troisieme_segpa_class_room = ClassRoom.find_by(school_track: :troisieme_segpa)
  with_class_name_for_defaults(Users::Employer.new(email: 'employer@ms3e.fr', password: 'review')).save!
  with_class_name_for_defaults(Users::God.new(email: 'god@ms3e.fr', password: 'review')).save!
  with_class_name_for_defaults(Users::Operator.new(email: 'operator@ms3e.fr', password: 'review', operator: Operator.first)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'main_teacher', class_room: troisieme_generale_class_room, email: 'main_teacher@ms3e.fr', password: 'review', school: School.first)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'main_teacher', class_room: troisieme_segpa_class_room, email: 'main_teacher_segpa@ms3e.fr', password: 'review', school: School.first)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'school_manager', email: "school_manager@#{School.first.email_domain_name}", password: 'review', school: School.first)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'other', email: 'other@ms3e.fr', password: 'review', school: School.first)).save!

  EmailWhitelist.create!(email: 'statistician@ms3e.fr', zipcode: 60)

  with_class_name_for_defaults(Users::Statistician.new(email: 'statistician@ms3e.fr', password: 'review')).save!
  with_class_name_for_defaults(Users::Student.new(email: 'student@ms3e.fr',       password: 'review', first_name: 'Nestor', last_name: 'Benzedine', school: School.first, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'student_other@ms3e.fr', password: 'review', first_name: 'Mohammed', last_name: 'Rivière', school: School.first, class_room: ClassRoom.troisieme_generale.first, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago)).save!
  with_class_name_for_defaults(Users::SchoolManagement.new(role: 'teacher', email: 'teacher@ms3e.fr', password: 'review', school: School.first)).save!
end

def populate_students
  class_room_1 = ClassRoom.first
  class_room_2 = ClassRoom.second
  class_room_3 = ClassRoom.third
  class_room_4 = ClassRoom.fourth
  school = class_room_1.school

  with_class_name_for_defaults(Users::Student.new(email: 'abdelaziz@ms3e.fr', password: 'review', first_name: 'Abdelaziz', last_name: 'Michau', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago, class_room: class_room_1)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'alfred@ms3e.fr', password: 'review', first_name: 'Alfred', last_name: 'Cali', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago, class_room: class_room_1)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'louis@ms3e.fr', password: 'review', first_name: 'Louis', last_name: 'Tardieu', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago, class_room: class_room_2)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'leon@ms3e.fr', password: 'review', first_name: 'Leon', last_name: 'Dupre', school: school, birth_date: 14.years.ago, gender: 'm', confirmed_at: 2.days.ago, class_room: class_room_2)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'martine@ms3e.fr', password: 'review',first_name: 'Martine', last_name: 'Perchot',  school: school, birth_date: 14.years.ago, gender: 'f', confirmed_at: 2.days.ago, class_room: class_room_3)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'alexandrine@ms3e.fr', password: 'review', first_name: 'Alexandrine', last_name: 'Gidonot',  school: school, birth_date: 14.years.ago, gender: 'f', confirmed_at: 2.days.ago, class_room: class_room_3)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'frederique@ms3e.fr', password: 'review', first_name: 'Frédérique', last_name: 'Dupin',  school: school, birth_date: 14.years.ago, gender: 'f', confirmed_at: 2.days.ago, class_room: class_room_4)).save!
  with_class_name_for_defaults(Users::Student.new(email: 'karima@ms3e.fr', password: 'review', first_name: 'Karima', last_name: 'Belgarde',  school: school, birth_date: 14.years.ago, gender: 'f', confirmed_at: 2.days.ago, class_room: class_room_4)).save!
end

def populate_internship_offers
  # 3eme_generale: public sector
  InternshipOffers::WeeklyFramed.create!(
    employer: Users::Employer.first,
    weeks: Week.selectable_on_school_year,
    sector: Sector.first,
    group: Group.is_private.first,
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
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'bilbotron',
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
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'bilbotron',
    school_track: :troisieme_generale
  )
  # Bac_pro
  InternshipOffers::FreeDate.create!(
    employer: Users::Employer.first,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Boucherie Sanzos - gestion des approvisionnements frontaliers',
    description_rich_text: 'Vous assistez la responsable de secteur dans la gestion de la logistique routière et ferrée des approvisionnements de viande en provenance d\'Europe et d\'Argentine.',
    employer_description_rich_text: "La Boucherie Sanzos doit sa réputation à la qualité de sa viande reconnue et convoitée par plus de la moitié des restaurateurs haut de gamme de la ville de Paris.",
    employer_website: 'http://www.dtpm.fr/',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'bilbotron',
    school_track: :bac_pro
  )
  # Bac_pro
  InternshipOffers::FreeDate.create!(
    employer: Users::Employer.first,
    sector: Sector.first,
    group: Group.is_private.first,
    is_public: false,
    title: 'Scierie Descloux - maitrise des machines outils',
    description_rich_text: 'Vous assistez la responsable de production dans la conception, l\'exécution de commandes pour différents clients.',
    employer_description_rich_text: "La scierie Descloux attire des clients européens par la qualité de ses réalisations et la rapidité de ses livraisons point à point",
    employer_website: 'http://www.dtpm.fr/',
    tutor_name: 'Martin Fourcade',
    tutor_email: 'fourcade.m@gmail.com',
    tutor_phone: '+33637607756',
    street: '128 rue brancion',
    zipcode: '75015',
    city: 'paris',
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'bilbotron',
    school_track: :bac_pro
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
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'bilbotron',
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
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'bilbotron',
    school_track: :troisieme_prepa_metier
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
    coordinates: { latitude: 48.866667, longitude: 2.333333 },
    employer_name: 'bilbotron',
    school_track: :troisieme_segpa
  )
end

def populate_internship_weeks
  manager = Users::SchoolManagement.find_by(role: 'school_manager')
  school = manager.school
  school.week_ids = Week.selectable_on_school_year.pluck(:id)
end

def populate_applications
  bac_pro_studs = Users::Student.joins(:class_room)
                                .where('class_rooms.school_track = ?', :bac_pro)
                                .to_a
                                .shuffle
                                .first(2)
  trois_gene_studs = Users::Student.joins(:class_room)
                                   .where('class_rooms.school_track = ?', :troisieme_generale)
                                   .to_a
                                   .shuffle
                                   .first(2)
  troisieme_generale_offers = InternshipOffers::WeeklyFramed.where(school_track: :troisieme_generale)
  bac_pro_offers = InternshipOffers::FreeDate.where(school_track: :bac_pro)

  bac_pro_studs.each do |bac_pro_stud|
    InternshipApplications::FreeDate.create!(
      aasm_state: :submitted,
      submitted_at: 10.days.ago,
      internship_offer: bac_pro_offers.first,
      motivation: 'Au taquet',
      student: bac_pro_stud
    )
  end
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
  if trois_gene_studs&.second
    InternshipApplications::WeeklyFramed.create!(
      aasm_state: :approved,
      submitted_at: 10.days.ago,
      approved_at: 2.days.ago,
      student: trois_gene_studs.second,
      motivation: 'Au taquet',
      internship_offer: troisieme_generale_offers.first,
      internship_offer_week: troisieme_generale_offers.first.internship_offer_weeks.sample
    )
  end
end

def populate_aggreements
  application = InternshipApplication.find_by(aasm_state: 'approved')
  FactoryBot.create(
    :internship_agreement,
    internship_application: application,
    employer_accept_terms: true
  )
end

if Rails.env == 'review' || Rails.env.development?
  require 'factory_bot_rails'

  populate_week_reference
  populate_schools
  populate_class_rooms
  School.update_all(updated_at: Time.now)
  populate_operators
  populate_users
  populate_sectors
  populate_groups
  populate_internship_offers
  populate_students
  populate_internship_weeks
  populate_applications
  populate_aggreements
end
