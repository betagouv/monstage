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

  def user
    User.find_by(email: email) || email
  end

  rails_admin do
    list do
      field :id
      field :created_at
      field :user do
        pretty_value do
          user = bindings[:object].user
          if user.is_a?(User)
            path = bindings[:view].show_path(model_name: user.class.name, id: user.id)
            bindings[:view].content_tag(:a, user.email, href: path)
          else
            bindings[:object].email
          end
        end
      end
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
      states: {in_progress: 'label-warning', closed: 'label-success'}
    })
  end
end
