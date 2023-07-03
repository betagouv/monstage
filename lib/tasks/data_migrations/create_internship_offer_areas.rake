namespace :data_migrations do
  desc 'create internship offer areas for each employer'
  task migrate_group_names: :environment do
  klasses = [
      Users::Employer,
      Users::PrefectureStatistician,
      Users::MinistryStatistician,
      Users::EducationStatistician
  ]
  klasses.each do |klass|
    klass.find_each do |employer|
      employer.internship_offer_areas.find_or_create(name: "Mon espace")
    end
  end
end