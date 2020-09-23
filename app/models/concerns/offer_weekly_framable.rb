# frozen_string_literal: true

module OfferWeeklyFramable
  extend ActiveSupport::Concern

  included do
    validates :weeks, presence: { message: 'Veuillez saisir au moins une semaine de stage' }
    validates :max_candidates, numericality: { only_integer: true,
                                               greater_than: 0,
                                               less_than_or_equal_to: Offerable::MAX_CANDIDATES_PER_GROUP }
    after_initialize :init

    attr_reader :with_operator
  end

  def validate_group_is_public?
    return if group.nil?
    errors.add(:group, 'Veuillez choisir une institution de tutelle') unless group.is_public?
  end

  def validate_group_is_not_public?
    return if group.nil?
    errors.add(:group, 'Veuillez choisir une institution de tutelle') if group.is_public?
  end
end
