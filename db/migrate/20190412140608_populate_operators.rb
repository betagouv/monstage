class PopulateOperators < ActiveRecord::Migration[5.2]
  def change
    [
        "Clubs régionaux  d'entreprises pour l'insertion (CREPI)",
        "Dégun sans stage (Ecole centrale de Marseille)",
        "Fondation Agir contre l'Exclusion (FACE)",
        "JOB IRL",
        "Les entreprises pour la cité (LEPC)",
        "Un stage et après !",
        "Tous en stage",
        "Viens voir mon taf"
    ].each do |operator_name|
      operator = Operator.create(name: operator_name)
      InternshipOffer.where("operator_names @> ?", "{\"#{operator_name}\"}").each do |io|
        io.operators << operator
        io.save(validate: false)
      end
    end
  end
end
