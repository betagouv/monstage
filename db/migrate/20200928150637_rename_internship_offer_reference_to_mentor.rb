class RenameInternshipOfferReferenceToMentor < ActiveRecord::Migration[6.0]
  def change
    remove_reference :internship_offers, :mentor
    add_reference :internship_offers, :tutor, index: true
  end
end
