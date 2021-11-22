module OrganisationFormFiller
  def fill_in_organisation_form(is_public:, group:)
    fill_in 'Nom de l’entreprise proposant l’offre', with: 'Delta dev'
    find('label', text: 'Public').click
    select group.name, from: 'organisation_group_id' if group

    find('input[placeholder="Adresse"]').fill_in(with: 'paris 13eme')
    find('#test-input-full-address ul li:first-child').click
    fill_in "Rue ou compléments d'adresse", with: "La rue qui existe pas dans l'API / OSM"

    find('#organisation_employer_description_rich_text', visible: false).set("Une super cool entreprise")
    fill_in 'Site web (optionnel)', with: 'https://beta.gouv.fr/'
  end
end
