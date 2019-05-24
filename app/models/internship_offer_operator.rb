# frozen_string_literal: true

class InternshipOfferOperator < ApplicationRecord
  belongs_to :internship_offer
  belongs_to :operator, class_name: '::Operator'
end
