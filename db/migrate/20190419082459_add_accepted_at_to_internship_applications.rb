# frozen_string_literal: true

class AddAcceptedAtToInternshipApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_applications, :approved_at, :date
    add_column :internship_applications, :rejected_at, :date
    add_column :internship_applications, :convention_signed_at, :date
    InternshipApplication.where(aasm_state: :approved).update_all(approved_at: Date.today)
    InternshipApplication.where(aasm_state: :rejected).update_all(rejected_at: Date.today)
    InternshipApplication.where(aasm_state: :convention_signed).update_all(convention_signed_at: Date.today)
  end
end
