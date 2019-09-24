# frozen_string_literal: true

class School < ApplicationRecord
  include Nearbyable

  has_many :users, foreign_type: 'type'
  has_many :students, dependent: :nullify,
                      class_name: 'Users::Student'
  has_many :main_teachers, dependent: :nullify,
                           class_name: 'Users::MainTeacher'
  has_many :teachers, dependent: :nullify,
                      class_name: 'Users::Teacher'
  has_many :others, dependent: :nullify,
                    class_name: 'Users::Other'
  has_one :school_manager, class_name: 'Users::SchoolManager'

  has_many :class_rooms, dependent: :destroy
  has_many :school_internship_weeks, dependent: :destroy
  has_many :weeks, through: :school_internship_weeks

  before_save :lookup_department
  before_create :lookup_department

  VALID_TYPE_PARAMS = %w[rep rep_plus qpv qpv_proche]

  def select_text_method
    "#{name} - #{city} - #{zipcode}"
  end

  def lookup_department
    self.department = Department.lookup_by_zipcode(zipcode: zipcode) if zipcode.present?
  end

  def to_s
    name
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
      field :school_manager do
        visible true
        pretty_value do
          school_manager = bindings[:object].school_manager
          if school_manager.is_a?(Users::SchoolManager)
            path = bindings[:view].show_path(model_name: school_manager.class.name, id: school_manager.id)
            bindings[:view].content_tag(:a, school_manager.name, href: path)
          else
            nil
          end
        end
      end
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
        partial "void"
      end
      field :zipcode do
        partial "void"
      end
      field :city do
        partial "void"
      end
      field :department do
        partial "void"
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
    end
  end
end
