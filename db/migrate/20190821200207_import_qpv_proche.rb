class ImportQpvProche < ActiveRecord::Migration[5.2]
  GEOCODE_CACHE_FILE = Rails.root.join('db', 'data_imports','geocode_cache_qpv_proche.dump')

  def up
    return if Rails.env.test?
    geocode_searches_with_caching do
      CSV.foreach(Rails.root.join('db/data_imports/college-qpv-proche.csv'), headers: { col_sep: ',' })
         .each
         .with_index do |row, i|
        next if i.zero?
        school = School.new(
          code_uai: row['NUMERO_UAI'].strip,
          name: row['Patromyne établissement'].strip,
          city: row['Libellé Commune'].strip,
          department: row['Département'].strip,
          kind: :qpv_proche,
          visible: false
        )
        school.name = "Collège #{school.name}" unless school.name.start_with?(/coll.ge/i)
        school.name = school.name.strip.split(' ').map(&:capitalize).join(' ')
        school.city = school.city.strip.split(' ').map(&:capitalize).join(' ')

        query = "#{school.name} #{school.city}"
        result = Geocoder.search(query)
        location = result&.first&.geometry&.dig('location')
        if location
          school.city = result.first.city
          school.zipcode = result.first.postal_code
          school.coordinates = { latitude: location['lat'], longitude: location['lng'] }
          puts "ok: #{query}" if school.save
        else
          school.coordinates = { latitude: 0, longitude: 0 }
          if school.save
            puts "fail: #{query}"
          else
            puts "school not save : #{query}"
          end
        end


        puts "school created: #{school.inspect}"
      end
    end
  end

  def down
    School.where(kind: :qpv_proche).destroy_all
  end

  private
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
    fail 'FUCKIT cache failed'
    {}
  end

  def dump_cache(cache)
    File.write(GEOCODE_CACHE_FILE, YAML.dump(cache))
  end

end
