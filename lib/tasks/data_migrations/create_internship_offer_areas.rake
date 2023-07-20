namespace :data_migrations do

  desc 'create internship offer areas for each employer'
  task create_internship_offer_areas: :environment do
    # some cleaning before
    if Rails.env.production?
      InternshipOffer.find_by(id: 18509).try(:anonymize)
      InternshipOffer.find_by(id: 20255).try(:anonymize)
      InternshipOffer.find_by(id: 24571).try(:anonymize)
      InternshipOffer.find_by(id: 24709).try(:anonymize)
      InternshipOffer.find_by(id: 25041).try(:anonymize)
      InternshipOffer.find_by(id: 25043).try(:anonymize)
      InternshipOffer.find_by(id: 25044).try(:anonymize)
      InternshipOffer.find_by(id: 25425).try(:anonymize)
      InternshipOffer.find_by(id: 28770).try(:anonymize)
    end
    if Rails.env.staging?
      InternshipOffer.find_by(id: 895).try(:anonymize)
      InternshipOffer.find_by(id: 903).try(:anonymize)
      InternshipOffer.find_by(id: 909).try(:anonymize)
      InternshipOffer.find_by(id: 928).try(:anonymize)
      InternshipOffer.find_by(id: 929).try(:anonymize)
      InternshipOffer.find_by(id: 939).try(:anonymize)
      InternshipOffer.find_by(id: 1018).try(:anonymize)
      InternshipOffer.find_by(id: 1044).try(:anonymize)
      InternshipOffer.find_by(id: 1045).try(:anonymize)
    end
    User.kept.find_each do |user|
      next unless user.employer_like?
      next if user.internship_offer_areas.any?

      space = user.internship_offer_areas.build( name: "Mon espace", employer_type: 'User')
      space.save!
    end
  end

  desc 'create add area_reference to_internship offer'
  task add_area_reference_to_internship_offer: :environment do
    InternshipOffer.kept.find_each do |offer|
      print "."
      employer = User.find_by(id: offer.employer_id)

      puts "no_employer with offer##{offer.id}" if employer.nil?
      next if employer.nil?

      puts "#{employer.type}-offer##{offer.id}" unless employer.employer_like?
      next unless employer.employer_like?

      puts "no_area with offer##{offer.id}" if employer.internship_offer_areas.empty?
      next if employer.internship_offer_areas.empty?

      offer.update_columns(internship_offer_area_id: employer.internship_offer_areas.first.id)
    end
  end

  desc 'add employer reference to internship_offer from internship_offer_area'
  task add_employer_reference_to_internship_offer: :environment do
    InternshipOffer.kept.find_each do |internship_offer|
      next if internship_offer.internship_offer_area.nil?

      employer_id = internship_offer.internship_offer_area.employer_id
      internship_offer.update(employer_id: employer_id, employer_type: 'User')
    end
  end

  desc 'check migration went ok'
  task check_every_employer_has_its_space_and_references: :environment do
    InternshipOffer.kept.find_each do |internship_offer|
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