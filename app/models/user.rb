# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  validates :first_name, :last_name,
            presence: true

  validates_inclusion_of :accept_terms, in: ["1", true],
                                        message: :accept_terms,
                                        on: :create

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
    'Mon tableau'
  end

  def account_link_name
    'Mon profil'
  end

  def default_account_section
    'identity'
  end

  def custom_dashboard_paths
    [
      custom_dashboard_path
    ]
  end
end
