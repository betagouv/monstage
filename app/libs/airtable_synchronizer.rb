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
  }

  def pull_all
    AirTableRecord.destroy_all
    table.all.map { |record| import_record(record) }
  end

  def import_record(record)
    airtable_record = AirTableRecord.new
    MAPPING.map do |airtable_key, ar_key|
      airtable_record.attributes[ar_key] = record.attributes[airtable_key]
    end
    airtable_record.save!
  end

  private
  attr_reader :client, :table

  def initialize
    @client = Airtable::Client.new(Rails.application.credentials.dig(:air_table, :api_key))
    @table = client.table(Rails.application.credentials.dig(:air_table, :app_id),
                          Rails.application.credentials.dig(:air_table, :table))
  end
end
