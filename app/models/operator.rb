# frozen_string_literal: true

class Operator < ApplicationRecord
  AIRTABLE_CREDENTIAL_MAP = {
    'Un stage et après !' => :unstageetapres,
    'Le Réseau' => :lereseau,
    'Myfuture' => :myfuture,
    'Les entreprises pour la cité (LEPC)' => :lepc,
    'Tous en stage' => :tousenstage,
    'Viens voir mon taf' => :vvmt,
    'JobIRL' => :jobirl
  }

  has_many :operators, class_name: 'Users::Operator'
  has_many :remote_user_activities, dependent: :destroy
  has_many :internship_offers, through: :operators
  has_many :air_table_records
  scope :reportable, lambda { where(airtable_reporting_enabled: true) }

  rails_admin do
    weight 15
    navigation_label 'Divers'

    list do
      field :name
      field :target_count
    end
    show do
      field :name
      field :target_count
      field :logo
      field :website
    end
    edit do
      field :name
      field :target_count
      field :logo
      field :website
    end
  end
end
