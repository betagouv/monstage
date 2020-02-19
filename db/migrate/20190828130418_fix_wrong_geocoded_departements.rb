# frozen_string_literal: true

class FixWrongGeocodedDepartements < ActiveRecord::Migration[6.0]
  def change
    InternshipOffer.all.map do |internship_offer|
      internship_offer.reverse_department_by_zipcode
      begin
        if internship_offer.changed?
          internship_offer.save! && puts("changes: #{io.id}")
        end
      rescue StandardError => e
        puts "invalid: #{internship_offer.id}: #{internship_offer.errors.keys}"
      end
    end
  end
end
