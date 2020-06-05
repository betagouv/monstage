Ovh.configure do |config|
  config.application_key        =   ENV['ovh_application_key']
  config.application_secret     =   ENV['ovh_application_secret']
  config.consumer_key           =   ENV['ovh_consumer_key']
end