class FixInternshipOffersWithPublicPublicyAndPrivateGroupName < ActiveRecord::Migration[5.2]
  def change
    InternshipOffer.all
                   .reject(&:valid?)
                   .map { |io| io.update(is_public: false, group_name: "") }
  end
end
