# frozen_string_literal: true

class AddSubmittedAtToInternshipApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_applications, :submitted_at, :date
  end
end
