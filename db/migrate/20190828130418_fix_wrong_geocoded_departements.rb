class FixWrongGeocodedDepartements < ActiveRecord::Migration[6.0]
  def change
    InternshipOffer.all.map do |internship_offer|
      internship_offer.reverse_department_by_zipcode
      begin
        internship_offer.save! and puts "changes: #{io.id}" if internship_offer.changed?
      rescue => e
        puts "invalid: #{internship_offer.id}: #{internship_offer.errors.keys}"
      end
    end
  end
end
