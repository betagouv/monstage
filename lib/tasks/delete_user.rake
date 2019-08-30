# frozen_string_literal: true

desc 'Remove all information about a user (RGPD)'
task :delete_user, [:user_id] => :environment do |task, args|
  user_id = args.user_id

  puts "Removing all information about user #{user_id}..."

  user = User.find(user_id)

  # Remove all personal information
  user_fields_to_reset = {
    email: SecureRandom.hex, first_name: 'NA',
    last_name: 'NA', phone: nil, current_sign_in_ip: nil,
    last_sign_in_ip: nil, birth_date: nil, gender: nil, class_room_id: nil,
    resume_educational_background: nil, resume_other: nil,resume_languages: nil,
    handicap: nil
  }
  user.update_columns(user_fields_to_reset)

  # Remove information about internship applications
  if user.is_a?(Users::Student)
    user.internship_applications.each do |internship_application|
      internship_application.update(motivation: 'NA')
    end
  end

  # Remove information about internship offers
  if user.is_a?(Users::Employer)
    user.internship_offers.each do |internship_offer|
      internship_offer_fields_to_reset = {
        tutor_name: 'NA', tutor_phone: 'NA', tutor_phone: 'NA', title: 'NA',
        description: 'NA', employer_website: 'NA', street: 'NA',
        employer_name: 'NA', employer_description: 'NA', group: 'NA'
      }
      internship_offer.update(internship_offer_fields_to_reset)
      internship_offer.discard
    end
  end

  user.discard
  puts 'done'
end
