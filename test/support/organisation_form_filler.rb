module OrganisationFormFiller
  def fill_in_organisation_form(is_public:, group:)
    fill_in "Rechercher votre société dans l’Annuaire des Entreprises", with: '90943224700015'
    find("div.search-in-sirene ul[role='listbox'] li[id='downshift-0-item-0']").click
    find('label', text: 'Public').click if is_public  # Default is private
    select group.name, from: 'organisation_group_id' if group

    find('#organisation_employer_description_rich_text', visible: false).set("Une super cool entreprise")
    fill_in 'Site web (optionnel)', with: 'https://beta.gouv.fr/'
  end
end
