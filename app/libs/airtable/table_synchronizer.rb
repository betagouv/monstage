# frozen_string_literal: true
module Airtable
  class TableSynchronizer
    CAST_MAPPING = {
      "privé_/_public"=> :is_public,
      "filière"=> :school_track,
      "départements"=> :department_name,
      "operator_id" => :operator_id
    }

    COPY_MAPPING = {
      "nb_places_dispo"=> :nb_spot_available,
      "etablissement_des_élèves"=> :school_name,
      "nb_d'élèves_en_stage"=> :nb_spot_used,
      "nb_d'élèves_masculins"=> :nb_spot_male,
      "entreprise_d'accueil"=> :organisation_name,
      "secteur_d'activité"=> :sector_name,
      "sector_id"=>:sector_id,
      "group_id"=>:group_id,
      "school_id"=>:school_id,
      "week_id"=>:week_id,
      "created_by" => "created_by",
      "last_modified" => "updated_at",
      "type_de_stage"=> :internship_offer_type,
      "nb_d'élèves_féminins"=> :nb_spot_female
    }

    # main job, with some safe stuffs
    def pull_all
      ActiveRecord::Base.transaction do
        AirTableRecord.destroy_all
        table.all.map do |record|
          import_record(record)
        end
      end
    end

    # data integrity
    def import_record(record)
      attrs = {}
      CAST_MAPPING.map do |airtable_key, ar_key|
        attrs[ar_key] = send("cast_#{ar_key}", record.attributes[airtable_key])
      end
      COPY_MAPPING.map do |airtable_key, ar_key|
        attrs[ar_key] = record.attributes[airtable_key]
      end

      return if attrs.except(:is_public, :operator_id).values.all?(&:blank?)
      AirTableRecord.create!(attrs)
    end

    ### casting

    def cast_is_public(value)
      value != "Privé"
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

    def cast_operator_id(_)
      operator.id
    end

    def cast_department_name(value)
      Department::MAP[value]
    end

    private
    attr_reader :client, :table, :operator

    def initialize(operator:)
      @operator = operator
      @client = Airtable::Client.new(Rails.application.credentials.dig(:air_table, :api_key))
      @table = client.table(operator.airtable_app_id, operator.airtable_table)
    end

  end
end
