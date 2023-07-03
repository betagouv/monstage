namespace :data_migrations do
  desc 'create internship offer areas for each employer'
  task create_internship_offer_areas: :environment do
    klasses = [
        Users::Employer,
        Users::PrefectureStatistician,
        Users::MinistryStatistician,
        Users::EducationStatistician
    ]
    klasses.each do |klass|
      klass.find_each do |employer|
        InternshipOfferArea.find_or_create_by!(employer_id: employer.id, name: "Mon espace")
      end
    end
  end
end