# frozen_string_literal: true

class School < ApplicationRecord
  include Nearbyable
  include Zipcodable

  has_many :users, foreign_type: 'type'

  has_many :students, dependent: :nullify,
                      class_name: 'Users::Student'

  has_many :students_with_missing_school_week, dependent: :nullify,
                                               class_name: 'Users::Student'

  has_many :school_managements, dependent: :nullify,
                                class_name: 'Users::SchoolManagement'
  has_many :main_teachers, -> { where(role: :main_teacher) },
           class_name: 'Users::SchoolManagement'
  has_many :teachers, -> { where(role: :teacher) },
           class_name: 'Users::SchoolManagement'
  has_many :others, -> { where(role: :other) },
           class_name: 'Users::SchoolManagement'
  has_one :school_manager, -> { where(role: :school_manager) },
          class_name: 'Users::SchoolManagement'

  has_many :class_rooms, dependent: :destroy
  has_many :school_internship_weeks, dependent: :destroy
  has_many :weeks, through: :school_internship_weeks
  has_many :internship_offers, dependent: :nullify
  has_many :internship_applications, through: :students

  has_rich_text :agreement_conditions_rich_text

  validates :city, :name, :code_uai, presence: true

  validates :zipcode, zipcode: { country_code: :fr }

  VALID_TYPE_PARAMS = %w[rep rep_plus qpv qpv_proche].freeze

  scope :with_manager, lambda {
                         left_joins(:school_manager)
                           .group('schools.id')
                           .having('count(users.id) > 0')
                       }

  scope :without_weeks, lambda {
    left_joins(:weeks)
      .group('schools.id')
      .having('count(school_internship_weeks.school_id) = 0')
  }

  scope :missing_school_week_count_gt, lambda { |thresold|
    where('missing_school_weeks_count > ?', thresold)
  }

  def select_text_method
    "#{name} - #{city} - #{zipcode}"
  end

  def has_staff?
    users.where("role = 'teacher' or role = 'main_teacher' or role = 'other'")
         .count
         .positive?
  end

  def to_s
    name
  end

  def email_domain_name
    Academy.get_email_domain(Academy.lookup_by_zipcode(zipcode: zipcode))
  end

  def email_domain_name
    Academy.get_email_domain(Academy.lookup_by_zipcode(zipcode: zipcode))
  end

  rails_admin do
    list do
      field :id
      field :name
      field :visible
      field :kind
      field :address do
        pretty_value do
          school = bindings[:object]
          "#{school.city} – CP #{school.zipcode} (#{school.department})"
        end
      end
      field :school_manager
      field :city do
        visible false
      end
      field :department do
        visible false
      end
      field :zipcode do
        visible false
      end
    end

    edit do
      field :name
      field :visible
      field :kind, :enum do
        enum do
          VALID_TYPE_PARAMS
        end
      end
      field :code_uai

      field :coordinates do
        partial 'autocomplete_address'
      end

      field :class_rooms

      field :street do
        partial 'void'
      end
      field :zipcode do
        partial 'void'
      end
      field :city do
        partial 'void'
      end
      field :department do
        partial 'void'
      end
    end

    show do
      field :name
      field :visible
      field :kind
      field :street
      field :zipcode
      field :city
      field :department
      field :class_rooms
      field :internship_offers
      field :weeks do
        pretty_value do
          school = bindings[:object].weeks.map(&:short_select_text_method)
        end
      end
      field :school_manager
    end

    export do
      field :name
      field :zipcode
      field :city
      field :department
      field :kind
      field :school_manager, :string do
        export_value do
          bindings[:object].school_manager.try(:name)
        end
      end
      # Weeks are removed for now because it is not readable as an export
      field :weeks, :string do
        export_value do
          bindings[:object].weeks.map(&:short_select_text_method)
        end
      end
    end
  end
end
