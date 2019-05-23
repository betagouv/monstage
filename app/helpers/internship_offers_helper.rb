module InternshipOffersHelper
  def current_sector_name
    return Sector.find(params[:sector_id]).name if params[:sector_id]
    'Tous'
  end

  def current_sector_url
    return Sector.find(params[:sector_id]).external_url if params[:sector_id]
    'http://www.onisep.fr/Decouvrir-les-metiers/Des-metiers-par-secteur'
  end

  def options_for_group_names
    InternshipOffer::PUBLIC_GROUP_NAMES.map { |admin| [admin, { 'data-target' => "internship-form.groupNamePublic"}] } +
        InternshipOffer::PRIVATE_GROUP_NAMES.map { |admin| [admin, { 'data-target' => "internship-form.groupNamePrivate"}] }
  end
end
