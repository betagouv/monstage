# frozen_string_literal: true

class AddZammadIdToFeedbacks < ActiveRecord::Migration[6.0]
  def change
    add_column :feedbacks, :zammad_id, :string
  end
end
