# frozen_string_literal: true

class DropFeedbacksTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :feedbacks
  end
end
