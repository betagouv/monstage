# frozen_string_literal: true
module Airtable
  class TableSynchronizer

    CAST_MAPPING = {
      # bool
      "privé_/_public"=> :is_public,
      # enum
      "filière"=> :school_track,
      # reference, beware airtable returns an array for 1<->1 references
      "department_code"=> :department_name,
      "operator_id" => :operator_id,
      "sector_id"=>:sector_id,
      "group_id"=>:group_id,
      "school_id"=>:school_id,
      "week_id"=>:week_id,
      "created_by" => "created_by",
    }

    COPY_MAPPING = {
      "id" => :remote_id,
      "nombre_de_places_disponibles"=> :nb_spot_available,
      "nombre_d'élèves_en_stage"=> :nb_spot_used,
      "nombre_d'élèves_masculins"=> :nb_spot_male,
      "last_modified" => :updated_at,
      "type_de_stage"=> :internship_offer_type,
      "nombre_d'élèves_féminins"=> :nb_spot_female
    }

    # main job, with some safe stuffs
    def pull_all
      ActiveRecord::Base.transaction do
        school_year = SchoolYear::Floating.new_by_year(year: ENV['AIRTABLE_OPEN_YEAR'].split('-').first.to_i)
        operator.air_table_records.during_year(school_year: school_year).destroy_all # only destroy current year records
        table.all(view: "Reporting_template").map do |record|
          import_record(record) if belongs_to_open_airtable_year?(record)
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
    rescue ActiveRecord::RecordInvalid => invalid
      Rails.logger.info("Fail to import airtable record #{record.id} from #{operator.name}")
    end

    ### casting
    def cast_is_public(value)
      value != "Privé"
    end

    def cast_sector_id(array_value)
      array_value.try(:first)
    end

    def cast_group_id(array_value)
      array_value.try(:first)
    end

    def cast_school_id(array_value)
      array_value.try(:first)
    end

    def cast_week_id(array_value)
      array_value.try(:first)
    end

    def cast_created_by(reference_created_by)
      reference_created_by.try(:dig, "email")
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
      Department::MAP[value.try(:first)]
    end

    def belongs_to_open_airtable_year?(record)
      record["année"].first == ENV['AIRTABLE_OPEN_YEAR']
    end

    private
    attr_reader :client, :table, :operator

    def initialize(operator:)
      @operator = operator
      @client = Airtable::Client.new(ENV['AIRTABLE_API_KEY'])
      @table = client.table(operator.airtable_app_id, operator.airtable_table)
    end

  end
end
