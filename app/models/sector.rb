# frozen_string_literal: true

class Sector < ApplicationRecord
  has_many :internship_offers
  before_create :set_uuid

  MAPPING_COVER = {
    "Administration publique" => "administration.svg",
    "Agriculture" => "agriculture.svg",
    "Agroéquipement" => "agriculture.svg",
    "Architecture, urbanisme et paysage" => "architecture.svg",
    "Armée - Défense" => "armee.svg",
    "Art et design" => "art_design.svg",
    "Arts du spectacle" => "arts_spectable.svg",
    "Artisanat d'art" => "artisanat.svg",
    "Audiovisuel" => "audiovisuel.svg",
    "Automobile" => "automobile.svg",
    "Banque et assurance" => "banque.svg",
    "Bâtiment et travaux publics (BTP), industrie du BTP" => "btp.svg",
    "Commerce et distribution" => "commerce.svg",
    "Communication" => "communication.svg",
    "Comptabilité, gestion, ressources humaines" => "gestion.svg",
    "Conseil" => "banque.svg",
    "Culture et patrimoine" => "culture.svg",
    "Droit et justice" => "droit.svg",
    "Édition, librairie, bibliothèque" => "edition.svg",
    "Électronique" => "electronique.svg",
    "Emploi, ressources humaines" => "gestion.svg",
    "Énergie" => "energie.svg",
    "Enseignement, éducation" => "enseignement.svg",
    "Environnement, recyclage, valorisation des déchets" => "environnement.svg",
    "Filiere bois" => "filiere_bois.svg",
    "Hôtellerie, restauration" => "hotellerie_restauration.svg",
    "Immobilier, transactions immobilières" => "immobilier.svg",
    "Industrie alimentaire" => "industrie_alimentaire.svg",
    "Industrie chimique et pharmaceutique" => "industrie_alimentaire.svg",
    "Industrie, ingénierie industrielle" => "industrie.svg",
    "Informatique et réseaux" => "informatique.svg",
    "Jeu vidéo" => "informatique.svg",
    "Maintenance" => "industrie_energie.svg",
    "Marketing, publicité" => "marketing.svg",
    "Mécanique" => "mecanique.svg",
    "Médical" => "medical.svg",
    "Mode" => "mode.svg",
    "Paramédical" => "paramedical.svg",
    "Recherche" => "industrie_alimentaire.svg",
    "Sécurité"	=>  "securite.svg",
    "Services postaux"	=>  "postal.svg",
    "Social, services à la personne"	=>  "social.svg",
    "Sport"	=>  "sport.svg",
    "Tourisme"	=>  "tourisme.svg",
    "Traduction, interprétation" => "architecture.svg",
    "Transport et logistique"	=>  "transport.svg",
  }

  rails_admin do
    weight 15
    navigation_label 'Divers'

    list do
      field :name
      field :uuid
    end
    show do
      field :name
      field :uuid
    end
    edit do
      field :name
    end
  end

  def cover
    MAPPING_COVER[name] || 'default_sector.svg'
  end

  private

  def set_uuid
    self.uuid = SecureRandom.uuid if self.uuid.blank?
  end
end
