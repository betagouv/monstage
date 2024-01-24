class AddMetiersArtToSector < ActiveRecord::Migration[7.1]
  def up
    Sector.create!(name: 'Métiers d\'art')
  end

  def down 
    Sector.find_by(name: 'Métiers d\'art').destroy
  end
end
