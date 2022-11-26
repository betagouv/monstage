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
    if JSON.parse(body)['results']
      JSON.parse(body)['results'].each do |etablissement|
        etablissements << {
          siret: etablissement['siege']['siret'],
          uniteLegale: {
            denominationUniteLegale: etablissement['nom_complet']
          },
          adresseEtablissement: {
            numeroVoieEtablissement: etablissement['siege']['numero_voie'],
            typeVoieEtablissement: etablissement['siege']['type_voie'],
            libelleVoieEtablissement: "#{etablissement['siege']['numero_voie']} #{etablissement['siege']['type_voie']} #{etablissement['siege']['libelle_voie']}",
            codePostalEtablissement: etablissement['siege']['commune'],
            libelleCommuneEtablissement: etablissement['siege']['libelle_commune'] 
          }

        }
      end
    end
    {etablissements: etablissements}
  end

end

