# frozen_string_literal: true
require 'csv'

def siret
  siret = FFaker::CompanyFR.siret
  siret.gsub(/[^0-9]/, '')
end

def geo_point_factory_array(coordinates_as_array)
  type = { geo_type: 'point' }
  factory = RGeo::ActiveRecord::SpatialFactoryStore.instance
                                                   .factory(type)
  factory.point(*coordinates_as_array)
end

def with_class_name_for_defaults(object)
  object.first_name ||= FFaker::NameFR.first_name
  object.last_name ||= "#{FFaker::NameFR.last_name}-#{Presenters::UserManagementRole.new(user: object).role}"
  object.accept_terms = true
  object.confirmed_at = Time.now.utc
  object.current_sign_in_at = 2.days.ago
  object.last_sign_in_at = 12.days.ago
  object
end

def call_method_with_metrics_tracking(methods)
  methods.each do |method_name|
    ActiveSupport::Notifications.instrument "seed.#{method_name}" do
      send(method_name)
    end
  end
end

def find_default_school_during_test
  # School.find_by_code_uai("0781896M") # school at mantes lajolie, school name : Pasteur.
  School.find_by_code_uai("0752694W") # school at Paris, school name : Camille Claudel.
end

ActiveSupport::Notifications.subscribe /seed/ do |event|
  puts "#{event.name} done! #{event.duration}"
end

def prevent_sidekiq_to_run_job_after_seed_loaded
  Sidekiq.redis do |redis_con|
    redis_con.flushall
  end
end

if Rails.env == 'review' || Rails.env.development?
  Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |seed|
    puts "Loading #{seed}"
    load seed
  end

  School.update_all(updated_at: Time.now)
  prevent_sidekiq_to_run_job_after_seed_loaded
  Services::CounterManager.reset_internship_offer_counters
  Services::CounterManager.reset_internship_offer_weeks_counter
end