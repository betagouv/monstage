# frozen_string_literal: true

class ReImportSectorOnProduction < ActiveRecord::Migration[5.2]
  def change
    return unless Rails.env.production?

    references_path = Rails.root.join('db', 'reference.yml')
    references_content = File.read(references_path.to_s)
    preload_class = Sector
    sectors = YAML.safe_load(references_content)
    sectors.map do |sector|
      Sector.create(name: sector['name'],
                    external_url: sector['external_url'],
                    uuid: sector['uuid'])
    end
  end
end
