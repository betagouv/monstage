module TutorFormFiller
  def fill_in_tutor_form
    fill_in 'Nom du tuteur/trice', with: 'Brice Durand'
    fill_in 'Adresse électronique / Email', with: 'le@brice.durand'
    fill_in 'Numéro de téléphone', with: '0639693969'
    fill_in "Fonction du tuteur dans l'entreprise", with: 'responsable logistique'
  end
end
