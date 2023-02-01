module InternshipOfferInfoFormFiller
  # no_weeks means every week
  # ------------------------------
  def fill_in_internship_offer_info_form(sector:, weeks: [])
    fill_in 'Intitulé du stage', with: 'Stage de test'
    select sector.name, from: "Secteur d'activité" if sector
    find('#internship_offer_info_description_rich_text', visible: false).set("Le dev plus qu'une activité, un lifestyle.\n Venez découvrir comment créer les outils qui feront le monde de demain")
    find('label', text: 'Individuel').click

    if weeks.empty?
      within('#internship_offer_id_weeks.form-group') do
        find('input#all_year_long[type="checkbox"][name="all_year_long"]', wait: 3).check
      end
    else
      # ok --> refute  find("input#all_year_long[type='checkbox'][name='all_year_long']", visible: false).checked?
      execute_script("document.getElementById('week-container-weeks').classList.remove('d-none');")
      weeks.each do |week|
        within('#week-container-weeks') do
          find("label[for='internship_offer_info_week_ids_#{week.id}_checkbox']").click
        end
      end
    end
  end

  def fill_in_address
    fill_in 'Adresse du lieu où se déroule le stage', with: '12 rue Origet 37000 Tours'
    find("ul[role='listbox'] li#downshift-0-item-0[role='option']", wait: 3).click
  end
end