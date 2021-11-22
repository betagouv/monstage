module InternshipOfferInfoFormFiller
  def fill_in_internship_offer_info_form(sector:, weeks:, school_track:)
    if school_track
      select I18n.t("enum.school_tracks.#{school_track}"),
             from: 'internship_offer_info_school_track'
    end
    fill_in 'internship_offer_info_title', with: 'Delta dev'
    select sector.name, from: 'internship_offer_info_sector_id' if sector
    find('#internship_offer_info_description_rich_text', visible: false).set("Le dev plus qu'une activité, un lifestyle.\n Venez découvrir comment creer les outils qui feront le monde de demain")
    find('label', text: 'Individuel').click
  end

end
