module TutorFormFiller
  def fill_in_tutor_form
    fill_in 'Prénom du tuteur/trice', with: 'Brice'
    fill_in 'Nom du tuteur/trice', with: 'Durand'
    fill_in 'Adresse électronique / Email', with: 'le@brice.durand'
    fill_in 'tutor[phone]', with: '0639693969'
  end
end
