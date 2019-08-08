class ImportQpv < ActiveRecord::Migration[5.2]
  GEOCODE_CACHE_FILE = Rails.root.join('db', 'data_imports','geocode_cache_qpv.dump')

  def up
    return if Rails.env.test?
    geocode_searches_with_caching do
      CSV.foreach(Rails.root.join('db/data_imports/college-qpv.csv'), headers: { col_sep: ',' })
         .each
         .with_index do |row, i|
        next if i.zero?
        school = School.find_or_initialize_by(
          code_uai: row['Code UAI'].strip,
          name: row['ETABLISSEMENT'].strip,
          city: row['Commune'].strip,
          department: row['Département'].strip,
          kind: :qpv
        )
        school.name = "Collège #{school.name}" unless school.name.start_with?(/coll.ge/i)
        school.name = school.name.strip.split(' ').map(&:capitalize).join(' ')
        school.city = school.city.strip.split(' ').map(&:capitalize).join(' ')

        query = "#{school.name} #{school.city}"
        result = Geocoder.search(query)
        location = result&.first&.geometry&.dig('location')
        if location
          school.zipcode = result.first.postal_code
          school.coordinates = { latitude: location['lat'], longitude: location['lng'] }
          school.save!
          puts "ok: #{query}"
        else
          puts "ko: #{query}"
        end
        puts "school created: #{school.inspect}"
      end
    end
  end

  def down
    School.where(kind: :qpv).destroy_all

  end

  private
  def geocode_searches_with_caching
    cache = load_cache
    Geocoder.configure(lookup: :google,
                       api_key: Credentials.enc(:google_api_key, prefix_env: false),
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

