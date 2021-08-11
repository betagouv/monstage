# postgis type
require "nested_form/engine"
require "nested_form/builder_mixin"
class RailsAdmin::Config::Fields::Types::Geography < RailsAdmin::Config::Fields::Types::Hidden
  RailsAdmin::Config::Fields::Types.register(self)
end
# daterange type
class RailsAdmin::Config::Fields::Types::Daterange < RailsAdmin::Config::Fields::Base
  RailsAdmin::Config::Fields::Types::register(self)
end

require Rails.root.join('lib', 'rails_admin', 'kpi.rb')
require Rails.root.join('lib', 'rails_admin', 'switch_user.rb')

RailsAdmin.config do |config|
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
    navigation_icon 'icon-user'
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

    switch_user

    export
  end

  config.included_models = %w[EmailWhitelists::Statistician
                              EmailWhitelists::Ministry
                              School
                              Sector
                              Group
                              User
                              InternshipOfferKeyword
                              InternshipOffers::WeeklyFramed
                              InternshipOffers::FreeDate
                              InternshipOffers::Api
                              Operator
                              Organisation
                              Tutor
                              Users::Student
                              Users::SchoolManagement
                              Users::Statistician
                              Users::MinistryStatistician
                              Users::Operator
                              Users::Employer
                              Users::God]

  config.navigation_static_links = {
    "Stats" => "/reporting/dashboards?school_year=#{SchoolYear::Current.new.beginning_of_period.year}",
    "Sidekiq" => "/sidekiq",
    "Zammad (Support)" => "https://monstage.zammad.com",
    "AB Testing" => "/split"
  }
end
