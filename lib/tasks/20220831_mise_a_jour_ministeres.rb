desc "Mise à jour des ministères suite au changement de gouvernement en 2022"
task 20220831_mise_a_jour_ministeres: :environment do
  ancien_ministere = Group.find_by(name: "MINISTÈRE DE L'ACTION ET DES COMPTES PUBLICS")
  nouveau_ministere = Group.find_by(name: "Ministère de l'Économie, des Finances et de la Souveraineté industrielle et numérique")

  InternshipOffer.where(group_id: ancien_ministere.id).update_all(group_id: nouveau_ministere.id)
  ancien_ministere.destroy

  ancien_ministere = Group.find_by(name: "MINISTÈRE DE LA COHÉSION DES TERRITOIRES ET DES RELATIONS AVEC LES COLLECTIVITÉS TERRITORIALES")
  nouveau_ministere = Group.find_by(name: "Ministère de la Transition écologique et de la Cohésion des territoires")

  InternshipOffer.where(group_id: ancien_ministere.id).update_all(group_id: nouveau_ministere.id)
end
