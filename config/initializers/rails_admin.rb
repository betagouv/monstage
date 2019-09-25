class RailsAdmin::Config::Fields::Types::Geography < RailsAdmin::Config::Fields::Types::Hidden
  RailsAdmin::Config::Fields::Types.register(self)
end
require Rails.root.join('lib', 'rails_admin', 'kpi.rb')
require Rails.root.join('lib', 'rails_admin', 'anonymize_user.rb')

RailsAdmin.config do |config|
  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == CancanCan ==
  config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

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
    state

    anonymize_user
  end

  config.included_models = %w[School
                              Feedback
                              InternshipOffer
                              Users::Student
                              Users::Employer
                              Users::SchoolManager
                              Users::MainTeacher
                              Users::Teacher
                              Users::Operator
                              Users::Other
                              Users::God
                              Users::Statistician
                              User]

  config.navigation_static_links = {
    "Delayed Job" => "/admin/delayed_job",
    "Zammad (Support)" => "https://monstage.zammad.com"
  }
end
