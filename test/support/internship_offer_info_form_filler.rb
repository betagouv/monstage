module InternshipOfferInfoFormFiller
  def fill_in_internship_offer_info_form(sector:)
    fill_in 'Métier(s) à découvrir', with: 'Stage de test'
    select sector.name, from: "Secteur d'activité" if sector
    find('#internship_offer_info_description',
         visible: false).set("Le dev plus qu'une activité, un lifestyle. Venez découvrir comment creer les outils qui feront le monde de demain")
  end
end
