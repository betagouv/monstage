# frozen_string_literal: true

require 'csv'
class RefactorSectorsWithOnisepSeeds < ActiveRecord::Migration[5.2]
  def change
    return
    former_sectors = Sector.all.entries
    new_sectors = []
    new_sector = nil
    CSV.foreach(Rails.root.join('db/data_imports/onisep-sectors.csv'), headers: { col_sep: ';' }) do |row, _i|
      new_sector = Sector.find_or_create_by(
        name: row['GFE'].strip,
        gfe_name: row['GFE'].strip
      )
      if row['nom publication'].present?
        new_sector.publication_name ||= row['nom publication'].strip
      end
      new_sector.save
      new_sectors.push(new_sector)
    end

    InternshipOffer.limit(new_sectors.size).all.each.with_index do |io, i|
      io.sector = new_sectors[i]
      io.save!
    end
    InternshipOffer.offset(new_sectors.size).all.each do |io|
      io.sector = new_sectors.sample
    end

    Sector.all.map do |s|
      s.destroy if s.internship_offers.count == 0
    end
  end
end
