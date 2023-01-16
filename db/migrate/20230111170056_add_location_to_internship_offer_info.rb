class AddLocationToInternshipOfferInfo < ActiveRecord::Migration[7.0]
  def up
    add_column :internship_offer_infos, :street, :string, null: true, limit: 255
    add_column :internship_offer_infos, :zipcode, :string, null: true, limit: 15
    add_column :internship_offer_infos, :city, :string, null: true, limit: 120
    add_column :internship_offer_infos, :coordinates, :st_point, geographic: true
    add_column :internship_offer_infos, :employer_name, :string, null: true, limit: 200
    add_column :internship_offer_infos, :manual_enter, :string, default: 'from migration', null: false, limit: 30

    add_index :internship_offer_infos, :coordinates, using: :gist

    TaskManager.new(
      allowed_environments: %w[all],
      task_name: 'migrations:set_internship_offer_info_location_from_organisation'
    ).play_task_once

  end

  def down
    remove_index :internship_offer_infos, name: :index_internship_offer_infos_on_coordinates

    remove_column :internship_offer_infos, :street
    remove_column :internship_offer_infos, :zipcode
    remove_column :internship_offer_infos, :city
    remove_column :internship_offer_infos, :coordinates
    remove_column :internship_offer_infos, :employer_name
    remove_column :internship_offer_infos, :manual_enter
  end
end
