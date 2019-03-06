class GeocodeSchools < ActiveRecord::Migration[5.2]
  GEOCODE_CACHE_FILE = Rails.root.join('db', 'geocode_cache.dump')

  def change
    geocode_searches_with_caching do
      School.all.map do |school|
        query = "#{school.name} #{school.city}"
        result = Geocoder.search(query)
        location = result&.first&.geometry&.dig("location")
        if location
          school.coordinates = geo_point_factory(latitude: location["lat"],
                                                 longitude: location["lng"])
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
    YAML.load(File.read(GEOCODE_CACHE_FILE))
  rescue Errno::ENOENT => error
    {}
  rescue SyntaxError => error
    puts "FUCKIT cache failed"
    {}
  end

  def dump_cache(cache)
    File.write(GEOCODE_CACHE_FILE, YAML.dump(cache))
  end
end
