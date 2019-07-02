module Dto
  class ActiveRecordToCsv
    require 'csv'

    def to_csv
      CSV.generate do |csv|
        csv << headers_column_names
        entries.map { |entry| csv << entry_to_csv_row(entry) }
      end
    end

    private
    attr_reader :entries, :headers, :csv

    def entry_to_csv_row(entry)
      headers_values_names.inject([]) do |row, key|
        if entry.respond_to?(key.to_sym) # method accessor entry.key()
          row.push(entry.send(key.to_sym))
        elsif entry.attributes[key.to_s] # attribute accessor entry["#{key}"]
          row.push(entry.attributes[key.to_s])
        else
          row.push(nil)
        end
        row
      end
    end

    def headers_column_names
      case headers
      when Array
        headers
      when Hash
        headers.values
      else
        fail "Unkown headers"
      end
    end

    def headers_values_names
      case headers
      when Array
        headers
      when Hash
        headers.keys
      else
        fail "Unkown values"
      end
    end

    def initialize(entries:, headers:)
      @entries = entries
      @headers = headers
    end
  end
end
