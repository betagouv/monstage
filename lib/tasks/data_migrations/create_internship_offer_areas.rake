namespace :data_migrations do
  desc 'create internship offer areas for each employer'
  task create_internship_offer_areas: :environment do
    User.kept.find_each do |user|
      next unless user.employer_like?
      next if user.internship_offer_areas.any?

      space = user.internship_offer_areas.build( name: "Mon espace")
      space.save!
    end
  end

  desc 'create add area_reference to_internship offer'
  task add_area_reference_to_internship_offer: :environment do
  InternshipOffer.all.find_each do |offer|
      print "."
      employer = User.find(offer.employer_id)
      puts "no_employer with #{offer.id}" if employer.nil?
      puts "no_area with #{offer.id}" if employer.internship_offer_areas.empty?
      offer.update_column(:internship_offer_area_id, employer.internship_offer_areas.first.id)
    end
  end

  desc 'add employer reference to internship_offer from internship_offer_area'
  task add_employer_reference_to_internship_offer: :environment do
    InternshipOffer.all.find_each do |internship_offer|
      next if internship_offer.internship_offer_area.nil?
      employer_id = internship_offer.internship_offer_area.employer_id
      internship_offer.update(employer_id: employer_id, employer_type: 'User')
    end
  end

  desc 'add employer reference to internship_offer from internship_offer_area'
  task check_every_employer_has_its_space_and_references: :environment do
    InternshipOffer.all.find_each do |internship_offer|
      print "."
      raise "check internship_offers failed : internship_offer_area : #{internship_offer.id}" if internship_offer.internship_offer_area.nil?
      raise "check internship_offers failed : internship_offer : #{internship_offer.id}"  if internship_offer.employer_id.nil?
      raise "check internship_offers failed : employer_type : #{internship_offer.id}"  if internship_offer.employer_type.nil?
    end
    puts " fin check InternshipOffer"
    User.kept.find_each do |user|
      next unless user.employer_like?
      print "."

      raise "check users failed : internship_offer_area : #{user.id}" if user.internship_offer_areas.empty?
    end
    puts " fin check User"
  end
end