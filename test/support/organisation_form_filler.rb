module OrganisationFormFiller
  def fill_in_organisation_form(group:, is_public: false)
    a_siret = '90943224700015'
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
    stub_request(:get, "https://api.insee.fr/entreprises/sirene/siret/#{a_siret}").with(
      headers: {
        'Accept'=>'application/json',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization'=>'Bearer TOKEN',
        'Content-Type'=>'application/json',
        'Host'=>'api.insee.fr',
        'User-Agent'=>'Ruby'
      }
    ).to_return(status: 200, body:, headers: {})

    fill_in 'Rechercher votre société/administration dans l’annuaire des entreprises',
            with: a_siret
    find("#downshift-0-item-0").click
    find('label', text: 'Public').click if is_public  # Default is private
    select group.name, from: 'organisation_group_id' if group

    find('#organisation_employer_description_rich_text', visible: false).set("Une entreprise super cool ")
    fill_in 'Site web (optionnel)', with: 'https://beta.gouv.fr/'
  end
end
