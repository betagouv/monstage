require 'yaml'

class AddUidToSectors < ActiveRecord::Migration[5.2]
  def change
    add_column :sectors, :uuid, :string, null: false, default: ''
    Sector.all.map do |sector|
       sector.uuid = SecureRandom.uuid
       sector.save!
    end
  end
end
