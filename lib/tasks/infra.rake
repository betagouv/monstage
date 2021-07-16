namespace :infra do
    # heroku hack for review apps
    desc 'Send webhooks notification after review app deployed'
    task :notify_deployed do
      require 'net/http'
      require 'uri'

      heroku_app_name = "https://#{ENV.fetch('HEROKU_APP_NAME')}.herokuapp.com"
      payload = { "text" => "Review app ready : #{heroku_app_name}" }

      Net::HTTP.post(
        URI(Rails.application.credentials.dig(:webhooks, :mattermost_heroku_post_deploy)),
        payload.to_json,
        { "Content-Type" => "application/json" }
      )
    end

    # irb(main):003:0> Users::Student.where("created_at > ?", 1.year.ago).count
    # => 7975
    # irb(main):004:0> Users::Student.where("created_at > ?", 1.year.ago).where(class_room_id: nil).count
    # => 865
    desc 'pull some metrics /'
    task :metrics => :environment do
      total_student_last_year = Users::Student.where("created_at > ?", 1.year.ago).count
      total_student_last_year_without_class_room = Users::Student.where("created_at > ?", 1.year.ago).where(class_room_id: nil).count

      puts "total_student_last_year: #{total_student_last_year}"
      puts "total_student_last_year_without_class_room: #{total_student_last_year_without_class_room}"
      puts "percent total_student_last_year_without_class_room: #{total_student_last_year_without_class_room * 100 / total_student_last_year}%"
    end
end
