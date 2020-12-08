class AddTutorToInternshipOffer < ActiveRecord::Migration[6.0]
  def change
    remove_reference :internship_offers, :tutor
    add_reference :internship_offers, :tutor, foreign_key: { to_table: :users }
  end
end
