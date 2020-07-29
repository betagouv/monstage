class RailsAdmin::Config::Fields::Types::Geography < RailsAdmin::Config::Fields::Types::Hidden
  RailsAdmin::Config::Fields::Types.register(self)
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

  ## == CancanCan ==
  config.authorize_with :cancancan

  config.parent_controller = 'AdminController'

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

  config.included_models = %w[EmailWhitelist
                              School
                              Sector
                              Group
                              User
                              InternshipOfferKeyword
                              InternshipOffers::WeeklyFramed
                              InternshipOffers::Api
                              Users::Student
                              Users::SchoolManagement
                              Users::Statistician
                              Users::Operator
                              Users::Employer
                              Users::God]

  config.navigation_static_links = {
    "Stats" => "/reporting/dashboards",
    "Delayed Job" => "/admin/delayed_job",
    "Zammad (Support)" => "https://monstage.zammad.com"
  }
end
