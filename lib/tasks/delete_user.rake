# frozen_string_literal: true

desc 'Remove all information about a user (RGPD)'
task :delete_user, [:user_id] => :environment do |task, args|
  user_id = args.user_id

  puts "Removing all information about user #{user_id}..."

  user = User.find(user_id)
  user_fields_to_reset = {
    email: SecureRandom.hex, first_name: 'NA',
    last_name: 'NA', phone: nil, current_sign_in_ip: nil,
    last_sign_in_ip: nil, birth_date: nil, gender: nil, class_room_id: nil,
    resume_educational_background: nil, resume_other: nil,resume_languages: nil,
    handicap: nil
  }
  user.update_columns(user_fields_to_reset)

  user.discard
  puts 'done'
end
