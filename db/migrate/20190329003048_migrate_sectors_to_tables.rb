# frozen_string_literal: true

class MigrateSectorsToTables < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :sector_id, :bigint
    add_foreign_key :internship_offers, :sectors, column: :sector_id, primary_key: :id
    add_index :internship_offers, :sector_id

    [
      'Aérien, Aéronautique et Aéroportuaire',
      'Agriculture, Elevage, Pêche',
      'Agroalimentaire, Industrie agroalimentaire',
      'Animaux',
      'Artisanat, Commerce de détail',
      'Audiovisuel, Cinéma',
      'Audit, Comptabilité, Gestion',
      'Automobile',
      'Banque, Assurance, Finance',
      'Bâtiment, Travaux publics, Architecture',
      'Biologie, Chimie, Pharmacie',
      'Commerce, Vente, Distribution',
      'Communication, Médias',
      'Culture, Patrimoine',
      'Défense, Sécurité',
      'Design, Graphisme, Multimédia',
      'Direction générale, Stratégie, Conseil, Organisation',
      'Droit, Justice',
      'Edition, Bibliothèque, Livre',
      'Enseignement, Formation',
      'Environnement, Eau, Nature, Propreté',
      'Fonction publique',
      'Hôtellerie - Restauration',
      'Humanitaire',
      'Immobilier',
      'Industrie, Maintenance, Energie',
      'Informatique, Digital, Télécom',
      'Ingénierie',
      'Journalisme',
      'Langue',
      'Marketing',
      'Medical',
      'Mode, Luxe, Industrie textile',
      'Paramédical',
      'Psychologie',
      'Ressources Humaines',
      'Sciences Humaines et Sociales',
      'Sciences, Maths, Physique, Recherche',
      'Secrétariat, Accueil',
      'Services à la personne, Entretien',
      'Social, Vie associative',
      'Soins esthétiques, Coiffure',
      'Spectacle, Métiers de la scène',
      'Sport, Animation',
      'Tourisme, Loisirs',
      'Transport, Logistique'
    ].map.inject({}) do |_accu, label|
      sector = Sector.create(name: label)
      InternshipOffer.where(sector: label).update_all(sector_id: sector.id)
    end
  end
end
