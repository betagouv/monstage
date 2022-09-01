desc "Mise à jour des ministères suite au changement de gouvernement en 2022"
task 20220831_mise_a_jour_ministeres: :environment do
  puts "Renommage et mise au propre des ministères inchangés"

  Group.where(name: "PREMIER MINISTRE").update(name: "Premier ministre")
  Group.where(name: "MINISTÈRE DU TRAVAIL").update(name: "Ministère du Travail, du Plein emploi et de l'Insertion") 
  Group.where(name: "MINISTÈRE DES SPORTS").update(name: "Ministère des Sports et des Jeux Olympiques et Paralympiques")
  Group.where(name: "MINISTÈRE DES SOLIDARITÉS ET DE LA SANTÉ").update(name: "Ministère de la Santé et de la Prévention")
  Group.where(name: "MINISTÈRE DES OUTRE-MER").update(name: "Ministère des Outre-mer")
  Group.where(name: "MINISTÈRE DES ARMÉES").update(name: "Ministère des Armées")
  Group.where(name: "MINISTÈRE DE LA TRANSITION ÉCOLOGIQUE ET SOLIDAIRE").update(name: "Ministère de la Transition écologique et de la Cohésion des territoires")
  Group.where(name: "MINISTÈRE DE LA JUSTICE").update(name: "Ministère de la Justice")
  Group.where(name: "MINISTÈRE DE LA CULTURE").update(name: "Ministère de la Culture")
  Group.where(name: "MINISTÈRE DE L'ÉDUCATION NATIONALE ET DE LA JEUNESSE").update(name: "Ministère de l'Éducation nationale et de la Jeunesse")
  Group.where(name: "MINISTÈRE DE L'ÉCONOMIE ET DES FINANCES").update(name: "Ministère de l'Économie, des Finances et de la Souveraineté industrielle et numérique")
  Group.where(name: "MINISTÈRE DE L'INTÉRIEUR").update(name: "Ministère de l'intérieur")
  Group.where(name: "MINISTÈRE DE L'EUROPE ET DES AFFAIRES ÉTRANGÈRES").update(name: "Ministère de l'Europe et des Affaires étrangères")
  Group.where(name: "MINISTÈRE DE L'ENSEIGNEMENT SUPÉRIEUR, DE LA RECHERCHE ET DE L'INNOVATION").update(name: "Ministère de l'Enseignement supérieur et de la Recherche")
  Group.where(name: "MINISTÈRE DE L'AGRICULTURE ET DE L'ALIMENTATION").update(name: "Ministère de l'Agriculture et de la Souveraineté alimentaire")


  puts "Ministères à rattacher"

  ministeres_a_rattacher = [["MINISTÈRE DE L'ACTION ET DES COMPTES PUBLICS", "Ministère de l'Économie, des Finances et de la Souveraineté industrielle et numérique"], 
    ["MINISTÈRE DE LA COHÉSION DES TERRITOIRES ET DES RELATIONS AVEC LES COLLECTIVITÉS TERRITORIALES", "Ministère de la Transition écologique et de la Cohésion des territoires"]]
  ancien_ministere = Group.find_by(name: )
  nouveau_ministere = Group.find_by(name: )

  ministeres_a_rattacher.each do |ministere_a_rattacher|
    ancien_ministere = ministere_a_rattacher[0]
    nouveau_ministere = ministere_a_rattacher[1]
  
    InternshipOffer.where(group_id: ancien_ministere.id).update_all(group_id: nouveau_ministere.id)
    Organisation.where(group_id: ancien_ministere.id).update_all(group_id: nouveau_ministere.id)
    Users::MinistryStatistician.where(ministry_id: ancien_ministere.id).update_all(ministry_id: nouveau_ministere.id)
    EmailWhitelists::Ministry.where(group_id: ancien_ministere.id).update_all(group_id: nouveau_ministere.id)
    
    ancien_ministere.destroy
  end

  puts "Nouveaux ministères"
  
  Group.create(name: "Ministère de la Transition énergétique")
  Group.create(name: "Ministère de la Transformation et de la Fonction publiques")
end
