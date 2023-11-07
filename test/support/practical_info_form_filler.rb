module PracticalInfoFormFiller
  def fill_in_practical_infos_form
    fill_in 'Votre numéro de téléphone de correspondance', with: '+330623665555'
    fill_in 'Adresse', with: '1 rue du poulet 75001 Paris'
    within("#practical_info_weekly_hours_start") do
      select('08:00')
    end
    within("#practical_info_weekly_hours_end") do
      select('16:30')
    end
    fill_in ('Pause déjeuner'), with: "12:00-13:00 avec l'équipe"
  end
end