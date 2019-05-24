# frozen_string_literal: true

class SchoolInternshipWeek < ApplicationRecord
  belongs_to :school
  belongs_to :week
end
