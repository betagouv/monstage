# frozen_string_literal: true

class Feedback < ApplicationRecord
  validates :email, :comment, presence: true

  include AASM

  aasm do
    state :open, initial: true
    state :in_progress, :closed

    event :answer do
      transitions from: :open, to: :in_progress
    end

    event :close do
      transitions from: [:open, :in_progress], to: :closed
    end
  end

  rails_admin do
    list do
      field :id
      field :email
      field :comment
      field :aasm_state, :state
    end

    show do
      field :id
      field :email
      field :comment
      field :aasm_state, :state
    end

    state({
      # events: {close: 'btn-success', answer: 'btn-warning'},
      states: {open: 'label-important', in_progress: 'label-warning', closed: 'label-success'}
    })
  end
end
