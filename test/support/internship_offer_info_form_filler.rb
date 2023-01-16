module InternshipOfferInfoFormFiller
  def fill_in_internship_offer_info_form(sector:, weeks:)
    fill_in 'Intitulé du stage', with: 'Stage de test'
    select sector.name, from: "Secteur d'activité" if sector
    find('#internship_offer_info_description_rich_text', visible: false).set("Le dev plus qu'une activité, un lifestyle.\n Venez découvrir comment créer les outils qui feront le monde de demain")
    find('label', text: 'Individuel').click
    fill_in 'Adresse du lieu où se déroule le stage', with: '12 rue Origet 37000 Tours'
    find("ul[role='listbox'] li#downshift-0-item-0[role='option']", wait: 3).click
  end
end
