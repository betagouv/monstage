class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  validates :first_name, :last_name,
            presence: true

  delegate :url_helpers, to: :routes
  delegate :routes, to: :application
  delegate :application, to: Rails

  def targeted_internship_offers
    InternshipOffer.kept
  end

  def to_s
    "logged in as : #{type}[##{id}]"
  end

  def name
    "#{first_name} #{last_name}"
  end

  def after_sign_in_path
    custom_dashboard_path
  end

  def dashboard_name
    "Mon tableau"
  end

  def default_account_section
    'identity'
  end
end
