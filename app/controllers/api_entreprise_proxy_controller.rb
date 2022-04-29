# frozen_string_literal: true

# ad blockers can block API, so we proxy our calls to it.
# not the neciest solution, but safest
class ApiEntrepriseProxyController < ApplicationController
  def search
    response = Api::AutocompleteSirene.search_by_name(name: params[:name])
    render json: clean_response(response.body), status: response.code
  end

  def clean_response(body)
    etablissements = []
    JSON.parse(body)['etablissement'].each do |etablissement|
      etablissements << {
        siret: etablissement['siret'],
        uniteLegale: {
          denominationUniteLegale: etablissement['l1_normalisee']
        },
        adresseEtablissement: {
          numeroVoieEtablissement: '',
          typeVoieEtablissement: '',
          libelleVoieEtablissement: etablissement['l4_normalisee'],
          codePostalEtablissement: etablissement['code_postal'],
          libelleCommuneEtablissement: etablissement['libelle_commune'] 
        }

      }
    end
    {etablissements: etablissements}
  end

end

