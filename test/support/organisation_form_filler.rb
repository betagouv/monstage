module OrganisationFormFiller
  def fill_in_organisation_form(is_public:, group:)
    stub_request(:post, "https://api.insee.fr/token").
      with(
        body: {"grant_type"=>"client_credentials"},
        headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>"Basic #{ENV['API_SIRENE_SECRET']}",
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Host'=>'api.insee.fr',
              'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: {access_token: 'TOKEN'}.to_json, headers: {})

    body = File.read(
      Rails.root.join(
        *%w[test
            fixtures
            files
            api-insee-adresse-east-side-software.json]
      )
    )
    stub_request(:get, "https://api.insee.fr/entreprises/sirene/V3/siret?q=siret:90943224700015").
      with(
        headers: {
              'Accept'=>'application/json',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer TOKEN',
              'Content-Type'=>'application/json',
              'Host'=>'api.insee.fr',
              'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: body, headers: {})

    fill_in "Rechercher votre société dans l’annuaire des entreprises", with: '90943224700015'
    find("div.search-in-sirene ul[role='listbox'] li[role='option']").click
    find('label', text: 'Public').click if is_public  # Default is private
    select group.name, from: 'organisation_group_id' if group

    find('#organisation_employer_description_rich_text', visible: false).set("Une super cool entreprise")
    fill_in 'Site web (optionnel)', with: 'https://beta.gouv.fr/'
  end
end
