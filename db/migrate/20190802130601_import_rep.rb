

class ImportRep < ActiveRecord::Migration[5.2]
  GEOCODE_CACHE_FILE = Rails.root.join('db', 'data_imports', 'geocode_cache_rep.dump')

  def up
    add_column(:schools, :kind, :string)
    School.update_all(kind: :rep_plus)
    return if Rails.env.test?
    geocode_searches_with_caching do
      CSV.foreach(Rails.root.join('db/data_imports/college-rep.csv'), headers: { col_sep: ',' })
         .each
         .with_index do |row, i|
        next if i.zero?
        school = School.find_or_initialize_by(
          code_uai: row['Code UAI '].strip,
          name: row['Collèges '].strip,
          city: row['COMMUNE'].strip,
          department: row['Départements '].strip,
          kind: :rep
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
    School.where(kind: :rep).destroy_all
    remove_column(:schools, :kind)
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
    puts 'FUCKIT cache failed'
    {}
  end

  def dump_cache(cache)
    File.write(GEOCODE_CACHE_FILE, YAML.dump(cache))
  end
end
