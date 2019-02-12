class InternshipOffersController < ApplicationController

  def index
    @internship_offers = InternshipOffer.all
  end

  def show
    @internship_offer = InternshipOffer.find(params[:id])
  end

  def create
    @internship_offer = InternshipOffer.create(internship_offer_params)

    redirect_to internship_offer_path(@internship_offer)
  end

  def new
    @internship_offer = InternshipOffer.new
    @sectors = ['Aérien, Aéronautique et Aéroportuaire',
                "Agriculture, Elevage, Pêche",
                "Agroalimentaire, Industrie agroalimentaire",
                "Animaux",
                "Artisanat, Commerce de détail",
                "Audiovisuel, Cinéma",
                "Audit, Comptabilité, Gestion",
                "Automobile",
                "Banque, Assurance, Finance",
                "Bâtiment, Travaux publics, Architecture",
                "Biologie, Chimie, Pharmacie",
                "Commerce, Vente, Distribution",
                "Communication, Médias",
                "Culture, Patrimoine",
                "Défense, Sécurité",
                "Design, Graphisme, Multimédia",
                "Direction générale, Stratégie, Conseil, Organisation",
                "Droit, Justice",
                "Edition, Bibliothèque, Livre",
                "Enseignement, Formation",
                "Environnement, Eau, Nature, Propreté",
                "Fonction publique",
                "Hôtellerie - Restauration",
                "Humanitaire",
                "Immobilier",
                "Industrie, Maintenance, Energie",
                "Informatique, Digital, Télécom",
                "Ingénierie",
                "Journalisme",
                "Langue",
                "Marketing",
                "Medical",
                "Mode, Luxe, Industrie textile",
                "Paramédical",
                "Psychologie",
                "Ressources Humaines",
                "Sciences Humaines et Sociales",
                "Sciences, Maths, Physique, Recherche",
                "Secrétariat, Accueil",
                "Services à la personne, Entretien",
                "Social, Vie associative",
                "Soins esthétiques, Coiffure",
                "Spectacle, Métiers de la scène",
                "Sport, Animation",
                "Tourisme, Loisirs",
                "Transport, Logistique",
                "Multi-secteur"]
  end

  private

  def internship_offer_params
    params.require(:internship_offer)
        .permit(:title, :description, :sector, :can_be_applied_for, :week_day_start, :week_day_end, :excluded_weeks,
                :max_candidates, :max_weeks, :tutor_name, :tutor_phone, :tutor_email, :employer_website,
                :employer_description, :employer_street, :employer_zipcode, :employer_city, :supervisor_email, :is_public)
  end
end
