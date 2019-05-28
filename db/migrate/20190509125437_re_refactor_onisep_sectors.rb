# frozen_string_literal: true

require 'csv'
class ReRefactorOnisepSectors < ActiveRecord::Migration[5.2]
  def change
    rename_column :sectors, :gfe_name, :external_url

    Sector.reset_column_information
    
    former_sectors = Sector.all.entries
    new_sectors = []
    CSV.foreach(Rails.root.join('db/metiers_onisep-Sectors.csv'),
                headers: { col_sep: ';' }) do |row, _i|
      new_sector = Sector.find_or_create_by(
        name: row['Des métiers par Secteur'].strip,
        external_url: row['URL'].strip
      )
      new_sector.save
      new_sectors.push(new_sector)
    end

    InternshipOffer.all.each.with_index do |io, i|
      io.sector = if i <= new_sectors.size - 1
                    new_sectors[i]
                  else
                    new_sectors.sample
                  end
      io.save!
    end

    Sector.all.map do |s|
      s.destroy if s.internship_offers.count == 0
    end
  end
end
