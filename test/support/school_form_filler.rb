module SchoolFormFiller
  def fill_in_school_form
    body = File.read(
      Rails.root.join(
        *%w[test
            fixtures
            files
            api-address-paris-13.json]
      )
    )

    expected_endpoint = "https://api-adresse.data.gouv.fr/search?q=101+rue+de+rivol&limit=10"
    expected_response = { status: 200, body: body }
    stub_request(:get, expected_endpoint).to_return(expected_response)
    
    fill_in "Nom de l'établissement", with: 'Victor Hugo'
    fill_in 'school[code_uai]', with: '1234567A'
    select 'rep', from: 'school[kind]'
    fill_in 'Adresse du lieu où se déroule le stage', with: '101 rue de rivoli'
    find('#downshift-0-item-0').click
  end
end
