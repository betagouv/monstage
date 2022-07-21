# frozen_string_literal: true

class Sector < ApplicationRecord
  has_many :internship_offers
  before_create :set_uuid

  MAPPING_COVER = {
    "Administration publique" => "administration.svg",
    "Agriculture" => "agriculture.svg",
    "Architecture, urbanisme et paysage" => "architecture.svg",
    "Armée - Défense" => "armee.svg",
    "Art et design" => "art.svg",
    "Artisanat d'art" => "artisanat.svg",
    "Audiovisuel" => "audiovisuel.svg",
    "Automobile" => "automobile.svg",
    "Banque et assurance" => "banque.svg",
    "Bâtiment et travaux publics (BTP), industrie du BTP" => "btp.svg",
    "Commerce et distribution" => "commerce.svg",
    "Communication" => "communication.svg",
    "Culture et patrimoine" => "culture.svg",
    "Droit et justice" => "droit.svg",
    "Édition, librairie, bibliothèque" => "edition.svg",
    "Électronique" => "electronique.svg",
    "Emploi, ressources humaines" => "gestion.svg",
    "Enseignement, éducation" => "enseignement.svg",
    "Environnement, recyclage, valorisation des déchets" => "environnement.svg",
    "Immobilier, transactions immobilières" => "immobilier.svg",
    "Industrie alimentaire" => "industrie_alimentaire.svg",
    "Industrie chimique et pharmaceutique" => "industrie_energie.svg",
    "Industrie, ingénierie industrielle" => "industrie_energie.svg",
    "Informatique et réseaux" => "informatique.svg",
    "Jeu vidéo" => "informatique.svg",
    "Marketing, publicité" => "marketing.svg",
    "Mécanique" => "mecanique.svg",
    "Médical" => "medical.svg",
    "Mode" => "mode.svg",
    "Paramédical" => "paramedical.svg"
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
