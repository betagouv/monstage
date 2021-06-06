# frozen_string_literal: true

class AirtableSynchronizer
  MAPPING = {
    "type_de_stage"=> :internship_offer_type,
    "privé_/_public"=> :is_public,
    "nb_d'élèves_féminins"=> :nb_spot_female,
    "filière"=> :school_track,
    "nb_places_dispo"=> :nb_spot_available,
    "etablissement_des_élèves"=> :school_name,
    "nb_d'élèves_en_stage"=> :nb_spot_used,
    "nb_d'élèves_masculins"=> :nb_spot_male,
    "entreprise_d'accueil"=> :organisation_name,
    "secteur_d'activité"=> :sector_name,
    "départements"=> :department_name,
  }

  def pull_all
    ActiveRecord::Base.transaction do
      AirTableRecord.destroy_all
      table.all.map do |record|
        import_record(record)
      end
    end
  end

  def import_record(record)
    attrs = {}
    MAPPING.map do |airtable_key, ar_key|
      attrs[ar_key] = send("cast_#{ar_key}", record.attributes[airtable_key])
    end
    return if attrs.except(:is_public).values.all?(&:blank?)
    AirTableRecord.create!(attrs)
  end

  def cast_internship_offer_type(value)
    value
  end

  def cast_is_public(value)
    value != "Privé"
  end

  def cast_nb_spot_female(value)
    value
  end

  def cast_school_track(value)
    case value
    when "3e"
      :troisieme_generale
    when "3e Prépa métier"
      :troisieme_prepa_metiers
    when "3e Segpa"
      :troisieme_segpa
    else
      value
    end
  end

  def cast_nb_spot_available(value)
    value
  end

  def cast_school_name(value)
    value
  end

  def cast_nb_spot_used(value)
    value
  end

  def cast_nb_spot_male(value)
    value
  end

  def cast_organisation_name(value)
    value
  end

  def cast_sector_name(value)
    value
  end

  def cast_department_name(value)
    value
  end

  private
  attr_reader :client, :table

  def initialize()
    @client = Airtable::Client.new(Rails.application.credentials.dig(:air_table, :api_key))
    @table = client.table(Rails.application.credentials.dig(:air_table, :app_id),
                          Rails.application.credentials.dig(:air_table, :table))
  end
end
