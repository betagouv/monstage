# frozen_string_literal: true

class FixEmployerTypeOnInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    InternshipOffer.update_all(employer_type: 'User')
  end
end
