# frozen_string_literal: true

class GeocodeSchools < ActiveRecord::Migration[5.2]
  GEOCODE_CACHE_FILE = Rails.root.join('db', 'data_imports','geocode_cache.dump')

  def up
    geocode_searches_with_caching do
      School.all.map do |school|
        school.name = "Collège #{school.name}" unless school.name.start_with?(/coll.ge/i)
        school.name = school.name.strip.split(' ').map(&:capitalize).join(' ')
        school.city = school.city.strip.split(' ').map(&:capitalize).join(' ')

        query = "#{school.name} #{school.city}"
        result = Geocoder.search(query)
        location = result&.first&.geometry&.dig('location')
        if location
          school.postal_code = result.first.postal_code
          school.coordinates = { latitude: location['lat'], longitude: location['lng'] }
          school.save!
          puts "ok: #{query}"
        else
          puts "ko: #{query}"
        end
      end
    end
  end

  def geocode_searches_with_caching
    cache = load_cache
    Geocoder.configure(lookup: :google,
                       api_key: ENV['GOOGLE_API_KEY'],
                       cache: cache)
    yield
  ensure
    dump_cache(cache)
  end

  def load_cache
    YAML.safe_load(File.read(GEOCODE_CACHE_FILE))
  rescue Errno::ENOENT => e
    {}
  rescue SyntaxError => e
    puts 'FUCKIT cache failed'
    {}
  end

  def dump_cache(cache)
    File.write(GEOCODE_CACHE_FILE, YAML.dump(cache))
  end
end
