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
      field :city
      field :zipcode
      field :department
    end

    edit do
      field :name
      field :visible
      field :kind
      field :street do read_only true end
      field :zipcode do read_only true end
      field :city do read_only true end
      field :department do read_only true end
      field :class_rooms
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
