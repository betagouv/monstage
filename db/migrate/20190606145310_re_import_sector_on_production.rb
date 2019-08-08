# frozen_string_literal: true

class ReImportSectorOnProduction < ActiveRecord::Migration[5.2]
  def change
    return unless Rails.env.production?

    references_path = Rails.root.join('db', 'data_imports','reference.yml')
    references_content = File.read(references_path.to_s)
    preload_class = Sector
    sectors = YAML.load(references_content)
    first_sector = nil
    old_sector_ids = Sector.all.map(&:id)
    sectors.map do |sector|
      first_sector = Sector.create!(name: sector['name'],
                                    external_url: sector['external_url'],
                                    uuid: sector['uuid'])
    end
    InternshipOffer.update_all(sector_id: first_sector.id)
    Sector.where(id: old_sector_ids).destroy_all
  end
end
