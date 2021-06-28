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
end
