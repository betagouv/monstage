class RemoveOrganisationConstraintOnOffers < ActiveRecord::Migration[6.0]
  def change
    def change
      change_column_default :internship_offers, :street, nil
      change_column_default :internship_offers, :zipcode, nil
      change_column_default :internship_offers, :city, nil
      change_column_default :internship_offers, nil
    end
  end
end
