# postgis type
require "nested_form/engine"
require "nested_form/builder_mixin"
require "school_year/base"
require "school_year/current"
class RailsAdmin::Config::Fields::Types::Geography < RailsAdmin::Config::Fields::Types::Hidden
  RailsAdmin::Config::Fields::Types.register(self)
end
# daterange type
class RailsAdmin::Config::Fields::Types::Daterange < RailsAdmin::Config::Fields::Base
  RailsAdmin::Config::Fields::Types::register(self)
end

# https://github.com/railsadminteam/rails_admin/issues/2502#issuecomment-504612818 lead to the following monkey-patch
class RailsAdmin::Config::Fields::Types::Json
  register_instance_option :formatted_value do
    if value.is_a?(Hash) || value.is_a?(Array)
      JSON.pretty_generate(value)
    else
      value
    end
  end

  def parse_value(value)
    value.present? ? JSON.parse(value) : nil
  rescue JSON::ParserError
    value
  end
end

require Rails.root.join('lib', 'rails_admin', 'config', 'actions', 'kpi.rb')
require Rails.root.join('lib', 'rails_admin', 'config', 'actions', 'switch_user.rb')
stats_path = "/reporting/dashboards?school_year=#{SchoolYear::Current.new.beginning_of_period.year}"

RailsAdmin.config do |config|

  config.asset_source = :webpacker
  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)
  config.main_app_name = ["Mon stage de 3e"]

  ## == CancanCan ==
  config.authorize_with :cancancan

  config.parent_controller = 'AdminController'
  config.model 'User' do
    navigation_icon 'fas fa-user'
  end

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard do
      show_in_navigation false
    end
    root :kpi do
      show_in_navigation false
    end

    index
    new
    bulk_delete
    show
    edit
    delete

    switch_user do
      except ['Users::God']
    end

    export
  end

  config.default_items_per_page = 50

  config.included_models = %w[School
                              Sector
                              Group
                              User
                              InternshipOfferKeyword
                              InternshipOffers::WeeklyFramed
                              InternshipOffers::Api
                              InternshipApplication
                              InternshipAgreement
                              Operator
                              Organisation
                              Tutor
                              Users::Student
                              Users::SchoolManagement
                              Users::PrefectureStatistician
                              Users::MinistryStatistician
                              Users::EducationStatistician
                              Users::Operator
                              Users::Employer
                              Users::God]

  config.navigation_static_links = {
    "Ajouter un établissement" => "/ecoles/nouveau",
    "Stats" => stats_path,
    "Sidekiq" => "/sidekiq",
    "Zammad (Support)" => "https://monstage.zammad.com",
    "AB Testing" => "/split"
  }


end
