class NormalizeSchoolAddresses < ActiveRecord::Migration[5.2]
  GEOCODE_CACHE_FILE = Rails.root.join('db', 'data_imports','normalize-school-addresses-components.dump')

  def up
    return if Rails.env.test?
    errors = []
    geocode_searches_with_caching do
      School.all.map do |school|
        query = "#{school.department} #{school.city} #{school.zipcode}"
        result = Geocoder.search(query)
        location = result&.first&.geometry&.dig('location')
        if location
          school.city = result.first.city
          school.zipcode = result.first.postal_code if school.zipcode.nil?
          if school.zipcode.nil?
            puts "ERROR: #{school.id}"
            errors.push(school.id)
            next
          else
            school.save
            puts "ok: #{school.id}"
          end
        else
          puts "ERROR: #{school.id}"
          errors.push(school.id)
        end
      end
    end
    puts errors
  end

  def geocode_searches_with_caching
    cache = load_cache
    Geocoder.configure(lookup: :google,
                       api_key: Rails.application.credentials.dig(:google_api_key),
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
